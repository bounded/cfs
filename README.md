What it is
----------

CFS is a literal-based database that can be used as a digital notebook. It is inspired by set theory.

Dive in
--------
Clone the repository with
```
$ git clone https://github.com/bounded/cfs
```

Now, you can have a look at the "input" file to get an idea of what the syntax looks like. Assuming that your Ruby version is 1.9.3 or higher, run
```
$ cd cfs
$ ruby main.rb
```

The database defined by "input" will be displayed. Type in some queries and observe their results. Suggestions: 
* todo
* projs, finished
* "The Dawn: of Time", chapter 1

How it works
-------------

This section explains the main ideas behind CFS and describes the syntax that it uses.

First and foremost, a database consists of a set of literals. Literals are atomic pieces of informations such as notes, ideas, URLs, text snippets, names, telephone numbers or file descriptors. 

Each literal can have additional meta-data by specifying an arbitrary number of containers that include it. A container can be interpreted as a "tag". More precisely, it defines a subset of the database. For example, the literal "Do laundry" may be inside the container "todo". 

Specifying more than one container is equivalent to specifying the intersection of these containers. Using the last example, "Do laundry" may be included in both "todo" and "tomorrow". In this case, the syntax would look like this:
```
todo, tomorrow: Do laundry
```
Everything after the first colon is the literal itself ("Do laundry"). Everything before is a comma separated list of containers that include it ("todo, tomorrow").

You can also do something like this:
```
novel, chapter 3: A man walked into a bar.
```

In this case, the literal "A man walked into a bar." has three containers: "novel", "chapter" and "chapter 3". The last two are created by the blank between "chapter" and "3". The blank also specifies that "chapter 3" is a subset of "chapter". In this case, you create a strict hierarchy of containers and thus a more complex structure than plain one-dimensional tags.

Using this technique, other types of relationships are possible: 
* "project alpha": an example of how you could structure your project notes
* "books history caesar": add more levels of depth
* "finished 01/10/13": add an attribute-value pair to your literal

As you can see in the "input" file, a database is defined by a collection of newline separated definitions of literals of the form 
```
$container1, ... , $containerN: $literal 
```
Querying the database is as intuitive as it gets: Just use the same syntax as you have used to define it, but only specify the containers. For example, use
```
todo, chapter 3
```
to receive every literal in the intersection of "todo", "chapter" and "chapter 3".

Future
------

Some things I plan to do:
* Loosen the syntax requirements. If you already have a database that is large enough, you can infer most of the syntax by using clever algorithms. Optimally, you should be able to perform something similar to a Google search on your database.
* Parse time and date.
* Port to another programming language.
