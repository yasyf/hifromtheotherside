## Setup Instructions

For the uninitiated:

Install `rvm` and the correct version of ruby, 2.3.1:

```bash
\curl -sSL https://get.rvm.io | bash -s stable --ruby
rvm install 2.3.1
rvm use 2.3.1
```

Install the ruby bundler:

```bash
gem install bundler
```

Then use the bundler to install packages in the Gemfile:

```bash
bundle install
```
