# Ruby test task for Hoodies


### How to install:
First, make sure that you have Ruby 3.1.0 installed on your machine (check rbenv/rvm/asdf)
clone repo to your machine and cd into it.
Install required gems:
```
$ bundle install
```

Run tests:
```
$ bundle exec rake test
```

Run rake task that builds report. You can change arguments for input or output as you like
```
$ bundle exec rake build_report[data_large.txt.gz, result.json]

# check the file
$ less result.json
```


Some additions that nice to have in a future:
* Checking crc of gz file
* Docker image to run app without ruby installed
* More explicit rendering of a process during results calculation
* Maybe some speed optimizations related to reading GZ file and parsing it 
* Maybe we can win some speed using Ractor, but requires experimenting



