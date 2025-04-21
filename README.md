## Getting started

```sh
bundle install
bin/dev
```

## Updating types

Re-generate our DSLs (after adding routes, etc.)

```sh
bundle exec tapioca dsl
```

Update types from a specific gem:

```sh
bundle exec tapioca gem actionmailer
```
