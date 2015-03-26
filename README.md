Jigsaw.rb 
=========
Is a simple ruby script for enumerating information about a company's employees.
It is useful for Social Engineering or Email Phishing

Help:
-----
	jigsaw.rb VERSION: 1.5.3 - UPDATED: 09/15/2013

	References:
		http://www.pentestgeek.com/2012/09/27/email-address-harvesting/

	Usage: jigsaw [options]

		example: jigsaw -s Google
    	
	-i, --id [Jigsaw Company ID]     The Jigsaw ID to use to pull records
    -P, --proxy-host [IP Address]    IP Address or Hostname of proxy server
    -p, --proxy-port [Port Number[   Proxy port
    -k, --keyword [Text String]      Text string contained in employee's title
    -s, --search [Company Name]      Name of organization to search for
    -r, --report [Output Filename]   Name to use for report EXAMPLE: '-r google' will generate 'google.csv'
    -d, --domain [Domain Name]       If you want you can specify the domain name to craft emails with
    -D, --debug                      Set this option to see HTTP requests/responses
    -v, --verbose                    Enables verbose output


Update 09/15/2013
-----------------
Added verbose percentage completed output when pulling records from
large companies.
Also added clean exiting from Ctrl-c interupt.


Update 07/18/2013
-----------------
The search functionality now works with an individual's name.  Its not perfect but based on the results the webpage returns jigsaw.rb can tell the difference between a search for a company or a person.  If a search for a person was provided all results are pulled down and displayed along with their name, title, company, city, state, and jigsawID.

	Example:
		./jigsaw.rb -s "Mark Maxey"
		Challenge not broken, attempting anyway.  Hold on to your butts!
		Possible matches for your search...
		Mark Maxey	Senior Security Consultant	Accuvant	Denver	CO	35807058
		Mark Maxey	Software Architect	Raytheon Company	Plano	TX	1701064
		Mark Maxey	Data Processing Executive Human Resources Executiv	Aetna Inc.	Hartford	CT	36912823
		Mark Maxey	Data Processing Executive Human Resources Executiv	TTI, Inc.	Fort Worth	TX	36912826
		Mark Maxey	Vice President Media Services	Yorktel	Eatontown	NJ	7391253
		Mark Maxey	Storage Consultant	Extra Space Storage Inc.	North Aurora	IL	25396456
		Mark Shampine	Information Technology Internet Manager	Bob Maxey Lincoln-Mercury Inc	Detroit	MI	57223017


Update 07/16/2013
-----------------
Update for version 1.5.2.  added functionality for keyword searching so for example the following returns only 10 records
with the string "security consultant" in their title.  Hope you enojy!
	
	./jigsaw.rb -i 23522 -d accuvant.com -k "security consultant"
	Extracting 304 records from 7 pages
	Kyle Johnson	Senior Security Consultant	kjohnson@accuvant.com	kyle.johnson@accuvant.com	Denver	CO
	Mark Maxey	Senior Security Consultant	mmaxey@accuvant.com	mark.maxey@accuvant.com	Denver	CO
	William Humphrey	Security Consultant	whumphrey@accuvant.com	william.humphrey@accuvant.com	Denver	CO
	Alan Humphrey	Security Consultant-Tallahassee, Florida	ahumphrey@accuvant.com	alan.humphrey@accuvant.com	Denver	CO
	Lee Baird	Security Consultant	lbaird@accuvant.com	lee.baird@accuvant.com	Denver	CO
	Rick Robinson	Senior Security Consultant	rrobinson@accuvant.com	rick.robinson@accuvant.com	Broomfield	CO
	Eric Minnesota	Security Consultant	eminnesota@accuvant.com	eric.minnesota@accuvant.com	Denver	CO
	Ken Hall	Wireless Security Consultant	khall@accuvant.com	ken.hall@accuvant.com	Denver	CO
	Michael Floerchinger	Senior Security Consultant	mfloerchinger@accuvant.com	michael.floerchinger@accuvant.com	Denver	CO
	Randy Conner	Senior Security Consultant	rconner@accuvant.com	randy.conner@accuvant.com	Denver	CO
	Dumped 10 records


Update 07/08/2013
-----------------
Small update for version 1.5.1.  It appears they are no longer using the bot_mitigation_token.  At the moment it looks like they are simply accepting scripted requests as is.  This is strange, we'll see how long this lasts...


Update 06/11/2013
-----------------
New version 1.5 is out.  with added 'breakbot.rb' library which tricks the Jigsaw server
into thinking we are a user on a browser and not an automated tool.  This allows us to do what ever
we want and not get stoped/blocked by their WAF

New Features:

	-Proxy support!  This allows you to run jigsaw through an HTTP proxy such as burp for further analysis or 
		staying annonymous

	-Debugging.  Now you can view each HTTP request/response if you want to troubleshoot the next time
		they figure out somethign to stop the tool


Update 10/20/2012
-----------------
Try the -d option to specify a domain to use to craft emails with

Example1:
---------
	$ ./jigsaw -s Google
	Your search returned more then one company
	Jigsaw ID: 215043	- Google, Inc.	6,627 employees.
	Jigsaw ID: 224667	- Google Postini Services	149 employees.
	Jigsaw ID: 439035	- AdMob Google Inc	2 employees.
	Jigsaw ID: 5032028	- Google Inc	1 employees.


Example2:
---------
	./jigsaw.rb -i 23522 -d accuvant.com -r Accuvant
	Extracting 314 records from 7 pages
	Generating the final Accuvant.csv report
	Wrote 310 records to Accuvant.csv
