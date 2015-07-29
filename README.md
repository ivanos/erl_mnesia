# erl_mnesia
Wrapper around mnesia to make it easier to share mnesia among several applications on the same Erlang node. The wrapper initializes mnesia. The applications call erl_mnesia to create or wait for their tables.

# Usage
Add erl_mnesia as a dependency to the application using mnesia. In sys.config for the node, add environment variables for erl_mnesia.

Variable | Description
-------- | -----------
options | list of options

The possible options are:

Option | Description
-------| -----------
persistent | Set schema's table copy type to `disc_copies`

Notes:
- Once the schema's table copy type is set to `disc_copies`, removing the `persistent` option does set the table copy back to `ram_copies`.

Applications using mnesia call `erl_mnesia:tables/1` early in their initialization with a list consisting key/value tuples, where the key is the table name and the value is the table definition. erl_mnesia creates the table if it does not already exist, or waits for the table if it does exist. `erl_mnesia:tables/1` does not return until all of the tables are created and ready.
