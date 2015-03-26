#!/usr/bin/env ruby
# Copyright (C) 2013 Royce Davis (@r3dy__)
# #
# #This program is free software: you can redistribute it and/or modify
# #it under the terms of the GNU General Public License as published by
# #the Free Software Foundation, either version 3 of the License, or
# #any later version.
# #
# #This program is distributed in the hope that it will be useful,
# #but WITHOUT ANY WARRANTY; without even the implied warranty of
# #MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
# #GNU General Public License for more details.
# #
# #You should have received a copy of the GNU General Public License
# #along with this program. If not, see <http://www.gnu.org/licenses/>

APP_ROOT = File.dirname(__FILE__)
$:.unshift( File.join(APP_ROOT, 'lib'))
require 'net/http'
require 'optparse'
require 'record'
require 'jigsawhttp'
require 'breakbot'

@cookies = ""
@threads = []
thread_count = 0
@records_harvested = 0

# If no arguments are passed at runtime display this suggestion
unless ARGV.length > 0
        puts "Try ./jigsaw.rb -h\r\n\r\n"
        exit
end

# These are the available runtime options
@options = {}
args = OptionParser.new do |opts|
  opts.banner = "Jigsaw.rb VERSION: 1.5.3 - UPDATED: 09/15/2013\r\n\r\n"
  opts.banner += "References:\r\n"
  opts.banner += "\thttp://www.pentestgeek.com/2012/09/27/email-address-harvesting/\r\n"
  opts.banner += "\thttps://github.com/AccuvantLABS/jigsaw\r\n\r\n"
  opts.banner += "Usage: jigsaw [options]\r\n\r\n"
  opts.banner += "\texample: jigsaw -s Google\r\n\r\n"
  opts.on("-i", "--id [Jigsaw Company ID]", "The Jigsaw ID to use to pull records") { |id| @options[:id] = id }
  opts.on("-P", "--proxy-host [IP Address]", "IP Address or Hostname of proxy server") { |proxy_host| @options[:proxy_host] = proxy_host }
  opts.on("-p", "--proxy-port [Port Number[", "Proxy port") { |port| @options[:proxy_port] = port }
  opts.on("-k", "--keyword [Text String]", "Text string contained in employee's title") { |keyword| @options[:keyword] = keyword }
  opts.on("-s", "--search [Company Name]", "Name of organization to search for") { |search| @options[:search] = search.to_s.chomp }
  opts.on("-r", "--report [Output Filename]", "Name to use for report EXAMPLE: \'-r google\' will generate \'google.csv\'") { |report| @options[:report] = report.to_s.chomp }
  opts.on("-d", "--domain [Domain Name]", "If you want you can specify the domain name to craft emails with") { |domain| @options[:domain] = domain.to_s.chomp }
  opts.on("-D", "--debug", "Set this option to see HTTP requests/responses") { |debug| @options[:debug] = true }
  opts.on("-v", "--verbose", "Enables verbose output\r\n\r\n") { |v| @options[:verbose] = true }
end
args.parse!(ARGV)

def finish_and_exit
  if @options[:report]
    Record.write_all_records_to_report(@options[:report])
  else
    Record.print_all_records_to_screen
  end
end

begin
  #if -s option is passed perform the search function
  if @options[:search]
    if !break_bot_challenge()
      puts "Challenge not broken, attempting anyway.  Hold on to your butts!"
    end
    result = search_for_company(@options[:search], @cookies)
    case
    when result.is_a?(Array)
      puts "Your search returned multiple results\r\n"
      result.each { |company|
        puts "ID: #{company["id"]}\tEmployees: #{company["records"]}\tName: #{company["name"]}"
      }
    when result.is_a?(Integer)
      puts "Jigsaw ID for #{@options[:search]} = #{result}"
    when result.is_a?(String)
      some_new_records = Array.new
      puts "Possible matches for your search...\r\n"
      result.split("-").each {|record|
        some_new_records << harvest_single_record("null", record, @cookies)
      }
      some_new_records.each { |rec| puts rec["firstname"] + " " + rec["lastname"] + "\t" + rec["title"] + "\t" + rec["company"] + "\t" + rec["city"] + "\t" + rec["state"] + "\t" + rec["ID"]}
    when result == nil
      puts "Your query did not return any results"
    end
    exit!
  end

  # if the -i option is passed
  if @options[:id]
    if !@options[:domain]
      puts "Please specify the -d option and set a domain to craft emails with.\r\n\r\n"
      exit!
    end
    break_bot_challenge()
    company_record_ids = []
    puts "Requesting the number of records for your search" if @options[:verbose]
    record_count = harvest_number_of_records(request_page("/SearchContact.xhtml?companyId=#{@options[:id]}&opCode=showCompDir", @cookies))
    page_count = get_number_of_pages(record_count)
    puts "Extracting #{record_count + 1} records from #{page_count} pages"
    page_count.times do |num|
      page = num + 1
      puts "Harvesting Record Numbers From Page: #{page}" if @options[:verbose]
      @threads << Thread.new {
        company_record_ids << harvest_record_ids(request_page("/SearchContact.xhtml?companyId=#{@options[:id]}&opCode=paging&rpage=#{page}&rowsPerPage=50", @cookies))
      }
    end
    @threads.each { |thread| thread.join }
    puts "Downloading information from #{record_count + 1} individual records.  This may take a while" if @options[:verbose]
    company_record_ids.each do |page|
      page.each do |id|
        @threads << Thread.new {
          if @options[:keyword]
            if record = harvest_single_record(@options[:id], id, @cookies, @options[:keyword])
              Record.new(record, @options[:domain])
            end
          else
            Record.new(harvest_single_record(@options[:id], id, @cookies), @options[:domain])
          end
        }
        if thread_count > 400
          @threads.each { |thread| thread.join }
          thread_count = 0
        end
        @records_harvested += 1
        Record.set_percent_complete(Numeric.percent_of(@records_harvested,(record_count + 1)))
      end
      print  "\r(Percent completed: #{Numeric.clean_up_percentage(Record.get_percent_complete.round(2))}%)"
      @threads.each { |thread| thread.join }
    end
  end
  puts "\r\nFinished."
  finish_and_exit
rescue => error_message
  puts "\r\nSomething went seriously wrong"
  puts error_message
  finish_and_exit
rescue SystemExit, Interrupt
  puts "\r\nCaught system interupt.  Program did not finish"
  finish_and_exit
end

