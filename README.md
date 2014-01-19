CFS is a literal-based database that can be used as a digital notebook. It is inspired by set theory.

Dive in
--------
Clone the repository with
```
$ git clone ...
```

Now, you can have a look at the "input" file to get an idea of what the syntax looks like. Assuming that your Ruby version is 1.9.3 or higher, run
```
$ cd cfs
$ ruby main.rb
```

The parsed database will be displayed. Type in some filters to see the result. Suggestions: "todo", "projs, finished", "\"The Dawn: of Time\", chapter 1".

How it works
-------------

This section explains the main ideas behind CFS and describes the syntax to use it.

A database consists of a set of literals. Literals are atomic pieces of informations such as notes, ideas, URLs, text snippets, names, telephone numbers or file descriptors. 

Each literal can have additional meta-data by specifying an arbitrary number of containers that include it. A container is a definition of a subset of the database and can be loosely interpreted as "tag". For example, the literal "Do laundry" may be inside the container "todo". 

Specifying more than one container is equivalent to assigning the literal to the intersection of these containers. Following the last example, "Do laundry" may be included in both "todo" and "tomorrow". In this case, the syntax would look like this:
```
todo, tomorrow: Do laundry
```

Everything that is to the right of the first colon is the literal. Everything to the left is a comma separated list of the containers that include this literal. 

You can also do something like this:
```
novel, chapter 3: A man walked into a bar.
```

In this case, the literal "A man walked into a bar." has three containers: "novel", "chapter" and "chapter 3". The last two are created by the blank between "chapter" and "3". It also specifies that "chapter 3" is a subset of "chapter". Here, you create a hierarchy of containers with a more complex structure rather than using plain one-dimensional tags.

Using this technique, other types of relationships are possible: 
* "project alpha": an example of how you could structure your project notes
* "books history romans": add more levels of depth
* "finished 01/10/13": add an attribute-value pair to your literal

As you can see in the "input" file, a database is defined by a collection of newline separated definitions of literals of the form "$container1, ..., $containerN: $literal". 

Querying the database is as intuitive as it gets: Just use the same syntax as you have used to define it, but leave out the colon and $literal part. This way, you receive all literals that are inside all of the specified containers.

Future
------

Some things I plan to do:
* Loosen the syntax requirements. Especially if you already have a database that is large enough, you can infer most of the syntax by using clever algorithms. Optimally, you should be able to perform something similar to a Google search on your database.
* Parse time and date.
* Port to another programming language.
