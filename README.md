This is mostly an app for Erik to refresh his Rails knowledge.

But it's also an AI-driven time management tool.

# Auth

### Google OAuth

Contact email: steadytime@googlegroups.com (https://groups.google.com/g/steadytime)
Project: https://console.cloud.google.com/auth/clients?invt=AbuZ4w&project=steadytime-dev

## Best practices

### Models

Generating models with string primary keys:

```sh
rails generate model GoogleAccount --primary-key=id id:string:index email:string ...
```

### Secrets

Editing credentials:

```sh
VISUAL="cursor --wait" rails credentials:edit --environment development
```

### Best practices for type checking


 - Use tapioca publicly maintained types whenever possible.
 - No need to add typed: true to files, we have typed: strict enabled at the top level.
 - Try to avoid T.unsafe by providing type hints for third party libraries. Use T.unsafe only as a last resort.

## Type checking

Skimming these docs is recommended to get a feel for how to use Sorbet:
- Gradual Type Checking: https://sorbet.org/docs/gradual
- Enabling Static Checks: https://sorbet.org/docs/static
- RBI Files: https://sorbet.org/docs/rbi

If you change models, routes, etc, you may need to regenerate the types for various helpers and such:

```sh
bin/tapioca dsl
```

## Design

 - "Don't forget" list (with some suggested tags, "today", "regularly", "soon", "eventually")
