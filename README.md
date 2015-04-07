# Installation
Assumes you have a newer version of ruby installed. You need the following gems.
```
gem install twitter
gem install rest-client
```
Also the config.yml must be edited to include twitter API tokens. Use http://52.4.188.24:3000 for rest address. 

# Running
```
ruby twitter-scaper.rb <hashtag w/out the #> <number of tweets to find>
ruby twitter-scaper.rb analytics 3
```

# Considerations
Seems to work best with low counts. Hangs up for some reason. Will get a 500 if the user already exists. 

# If I had more time
Write tests
Figure out why it hangs
Better exception handling





