# NAME

App::Jiffy - A minimalist time tracking app focused on precision and effortlessness.

# SYNOPSIS

    use App::Jiffy;

    # cmd line tool
    jiffy Solving world hunger
    jiffy Cleaning the plasma manifolds
    jiffy current # Returns the elapsed time for the current task

    # Run server
    jiffyd
    curl -d "title=Meeting with Client X" http://localhost:3000/timeentry

# DESCRIPTION

App::Jiffy's philosophy is that you should have to do as little as possible to track your time. Instead you should focus on working. App::Jiffy also focuses on precision. Many times time tracking results in globbing activities together masking the fact that your 5 hours of work on project "X" was actually 3 hours of work with interruptions from your coworker asking about project "Y".

In order to be precise with as little effort as possible, App::Jiffy will be available via a myriad of mediums and devices but will have a central server to combine all the information. Plans currently include the following applications:

- Command line tool
- Web app [App::Jiffyd](https://metacpan.org/pod/App::Jiffyd)
- iPhone app ( potentially )

# INSTALLATION

    curl -L https://cpanmin.us | perl - git://github.com/lejeunerenard/jiffy

# METHODS

The following are methods available on the `App::Jiffy` object.

## add\_entry

`add_entry` will create a new TimeEntry with the current time as the entry's start\_time.

## current\_time

`current_time` will print out the elapsed time for the current task (AKA the time since the last entry was created).

## time\_sheet

`time_sheet` will print out a time sheet including the time spent for each `TimeEntry`.

## search( `$query_text`, `$days` )

The `search` subcommand will look for the given `$query_text` in the past `$days` number of days. It will treat the `$query_text` argument as a regex.

## run

`run` will start an instance of the Jiffy app.

# AUTHOR

Sean Zellmer <sean@lejeunerenard.com>

# COPYRIGHT

Copyright 2015- Sean Zellmer

# LICENSE

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.
