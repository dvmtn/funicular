Funicular
=========

Taking [Rails](http://rubyonrails.org/) the scenic route up [Developer Mountain](http://devmountain.co.uk), this is a Rails template for creating new apps with our preferred setup.

Usage
-----
```
rails new <my_awesome_app> -d postgresql -T -m https://raw.githubusercontent.com/dvmtn/funicular/master/funicular.rb
```

Features
--------

- Rspec and Shoulda-matchers configured
- DatabaseCleaner ready to rock (Avdi Style)
- Guard & Spring setup for some fast feedback (especially within Tmux)
- Turbolinks & JQuery discreetly removed
- Haml installed and all default templates converted
- Better seeds layout for splitting up seeds files and option to load some data only in development
- More helpful SCSS/SASS file structure to aid writing tidy, focussed CSS
- [Rake n Bake](https://github.com/RichardVickerstaff/rake-n-bake) setup to keep your project healthy
- Better error pages
- Optionally create your databse for you
- Obligatory 'initial comit' in git
