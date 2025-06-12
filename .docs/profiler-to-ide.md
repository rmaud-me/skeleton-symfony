# Profiler to IDE

On symfony thanks to `framework.ide` configuration you can open on your ide, the file from the symfony profiler tool.
You can find all information on this page https://symfony.com/doc/current/reference/configuration/framework.html#ide

If you work on linux with phpstorm follow the advice about phpstorm-url-handler.

Once you install the phpstorm url handler (if needed), fill the `SYMFONY_IDE` variable with this kind of string :

For phpstorm
```dotenv
SYMFONY_IDE='phpstorm://open?file=%f&line=%l&{/project/path/on/docker/container}>{/project/path/on/my/machine/}'
```

In this project `{/project/path/on/docker/container}` equal to `/srv` and `{/project/path/on/my/machine/}` equal to the command result `pwd` when you are in your project folder.
