= Application Design and Architecture

Authors::    Daniela Ortiz
             Mauricio Cunillé
Date::      November 30, 2015

The directory structure for the application and its documentation is as follows:
   
   SoccerPool/
         ├─ doc/                                 Folder produced by RDoc.
         └─ src/                                 Folder for the application's source code.
              ├─ public/                         Folder for the server's public documents.
              │       └─ css/                    Folder for the application's CSS files.
              │       └─ bootstrap-3.3.6-dist/   Folder for the application's bootstrap files.
              │       └─ images/                 Folder for the application's images.
              │       └─ jquery-1.9.1/           Folder for the application's jquery files.
              ├─ models/                         Folder for the application's models.
              ├─ controllers/                    Folder for the application's controllers.
              └─ views/                          Folder for the application's views (ERB files).
              

This is the command used to produce this documentation (running it from the +SoccerPool+ directory):

  rdoc --exclude ".json|.css" src

The root of the documentation should now be available at: +SoccerPool/doc/index.html+

== Installing and Running the Application

To run the _SoccerPool_ web server you only need to type the following command at the terminal from the +SoccerPool/src+ directory:

  ruby server_start.rb

Afterwards, point your web brower at the following URL: [http://localhost:4567]

== Class Diagrams


== Entity Relationship Diagram



== Deployment Diagram





== Patterns Used

- <b> Active Record </b>: The +account+ class is an active record representing a row in the accounts table. The +ActiveRecordModel+ is an active record template representing a row in the child table
The +Pool+ class is an active record representing a row in the pools table. The +pick+ class is an active record representing a row in the picks table. 
The +Match+ class is an active record representing a row in the matches table.
- <b> Domain-Specific Language</b>: The +server_start.rb+ file consists of a series of Sinatra _routes_. Sinatra is a DSL for creating web applications in Ruby.
- <b> Model-View-Controller</b>: The application follows the classical web implementation of the MVC architectural pattern. The models (+.rb+ files) and views (+.erb+ files) are stored in the corresponding +models+ and +views+ directory. The controllers are stored in the +controllers directory.
- <b> Metaprogramming </b>: 
- <b> Singleton </b>: The +server_config.rb+ file has a class ServerConfig that is a singleton class representing the server configuration.
- <b> Iterator </b>: This pattern is used every time we iterate on an array of variables.
- <b> Strategy </b>: 
- <b> Template </b>: The +ActiveRecordModel+ is an active record template that represents a row in the child table.

== Acknowledgments

This section is optional. If somebody helped you with your project make sure to include her or his name here.

== References

Mention here any consulted books or web resources. Examples:

- \J. Nunemaker <em> Rails Tips </em> 2008. Available through {http://www.railstips.org/blog/archives/2006/11/18/class-and-instance-variables-in-ruby/}

