TODO
====

- Proxy Fog "server" object
- Load metadata via ssh json (so we can update it)
- Save metadata (now happens in component.rb)


- Rethink the DSL (think of haproxy script for needs (including file templates))
- Think about how to handle Roles (multiple components forming a role)
- Think about separating installation and configuration? (config can change depending on situation)
-- First round: install all server with the correct role
-- Second round: update all configuration for the roles (including interaction)
- Think about the combination of components and servers, now the component is "server aware" it should not be
-- server.install(:ruby) ??

- Items: haproxy, firewall, nginx, custom git stuff, mysql, mongo, rabbitmq


- Implement dependencies

- Implement files with ERB templates
- Save to local tmp with random name, scp to the server



