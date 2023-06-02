# README

This is a repo for reproduction of issue reported here: https://github.com/rails/rails/issues/48375
### Issue:

Reported server timing data for partials appears to be inaccurate.  When nested partials are used, the reported data shows the partials taking more time to render than **the request in total**.  Stopwatch verification confirms timing in chrome & firefox.

Noted in FF, Chrome and Safari.


### Viewing reported server timings

1. open network tab
2. refresh page
3. click into the request for the page (probably localhost:3000)
4. click timings
5. server timings are at the bottom
6. look for the key `render_partial.action_view`

See also: https://github.com/rails/rails/pull/36289


### using the executable test case


```sh
cd executable_test_case
ruby test.rb
```

Observe 1 failed test.