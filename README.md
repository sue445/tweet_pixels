# Tweet pixels
![Tweet pixels](https://pixe.la/v1/users/sue445/graphs/tweets)

[![CircleCI](https://circleci.com/gh/sue445/tweet_pixels/tree/master.svg?style=svg&circle-token=29379467733b2fddc654d5a50208b6b9f593e472)](https://circleci.com/gh/sue445/tweet_pixels/tree/master)

## Requirements
* [Pixela](https://pixe.la/)
* [Twilog](https://twilog.org/)

## Usage
### 1. Register Pixela and create graph
```ruby
require "pixela"

client = Pixela::Client.new(username: "YOUR_NAME", token: "YOUR_TOKEN")

# register
client.create_user(agree_terms_of_service: true, not_minor: true)

# create graph
client.graph("tweets").create(name: "Daily tweets", unit: "Tweets", type: "int", color: "sora")
```

### 2. Register Environment Variables to CircleCI
* `TWITTER_ID`
* `PIXELA_USERNAME`
* `PIXELA_TOKEN`
* `PIXELA_GRAPH_ID`

![CircleCI](img/circleci.png)

## Development
### Setup
```bash
cp .env.example .env
vi .env
```
