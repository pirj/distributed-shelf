Distributred Shelf
===========

Shelf stores your files remotely. No changes required to existing codebase, all file related API runs out of the box.

Local setup
-----------

Install dshelf gem:

    $ sudo gem install dshelf

Using from Sinatra
------------------

Example here http://github.com/pirj/distributed-shelf-example

For every environment where used:

    configure :production do
      require 'dshelf'
      DistributedShelf::config = {
        :distributed_path => '/remote',
        :storage_url => ENV['DISTRIBUTED_SHELF_URL']
      }
    end

Deploying to Heroku
-------------------
To use Distributed Shelf on Heroku, install the distributed_shelf add-on:

  $ heroku addons:add distributed_shelf
