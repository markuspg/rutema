rutema_web [http://patir.rubyforge.org/rutema](http://patir.rubyforge.org/rutema)

##DESCRIPTION:
rutema_web is the web frontend for rutema. 

It can be used as a viewer for database files created with the rutema ActiveRecord reporter.
It also provides you with some basic statistics about the tests in your database in the form of 
diagrams of debatable aesthetics but undoubtable value!

##SYNOPSIS:
rutema_web config.yaml and browse to http://localhost:7000 for the glorious view

Here is a sample of the configuration YAML:
<pre>
--- 
:db: 
  :adapter: sqlite3
  :database: rutema_test.db
:settings: 
  :page_size: 10
  :last_n_runs: 20
  :port: 7000
  :show_setup_teardown: true
</pre>
The :db: section should be the activerecord adapter configuration. The :settings: section controls the behaviour of the web app.

##REQUIREMENTS:
* rutema (http://patir.rubyforge.org/rutema)
* sinatra (http://www.sinatrarb.com/)
* ruport (http://rubyreports.org/)

##INSTALL:
* sudo gem install rutema_web

##LICENSE:
(The Ruby License)

rutema is copyright (c) 2007 - 2010 Vassilis Rizopoulos

You can redistribute it and/or modify it under either the terms of the GPL
(see COPYING.txt file), or the conditions below:

  1. You may make and give away verbatim copies of the source form of the
     software without restriction, provided that you duplicate all of the
     original copyright notices and associated disclaimers.

  2. You may modify your copy of the software in any way, provided that
     you do at least ONE of the following:

       a) place your modifications in the Public Domain or otherwise
          make them Freely Available, such as by posting said
	  modifications to Usenet or an equivalent medium, or by allowing
	  the author to include your modifications in the software.

       b) use the modified software only within your corporation or
          organization.

       c) rename any non-standard executables so the names do not conflict
	  with standard executables, which must also be provided.

       d) make other distribution arrangements with the author.

  3. You may distribute the software in object code or executable
     form, provided that you do at least ONE of the following:

       a) distribute the executables and library files of the software,
	  together with instructions (in the manual page or equivalent)
	  on where to get the original distribution.

       b) accompany the distribution with the machine-readable source of
	  the software.

       c) give non-standard executables non-standard names, with
          instructions on where to get the original software distribution.

       d) make other distribution arrangements with the author.

  4. You may modify and include the part of the software into any other
     software (possibly commercial).  But some files in the distribution
     are not written by the author, so that they are not under this terms.

     They are gc.c(partly), utils.c(partly), regex.[ch], st.[ch] and some
     files under the ./missing directory.  See each file for the copying
     condition.

  5. The scripts and library files supplied as input to or produced as 
     output from the software do not automatically fall under the
     copyright of the software, but belong to whomever generated them, 
     and may be sold commercially, and may be aggregated with this
     software.

  6. THIS SOFTWARE IS PROVIDED "AS IS" AND WITHOUT ANY EXPRESS OR
     IMPLIED WARRANTIES, INCLUDING, WITHOUT LIMITATION, THE IMPLIED
     WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR
     PURPOSE.