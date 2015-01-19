Lua object model
================

Simple object model implementation in Lua.

Inspired by [http://lua-users.org/wiki/SimpleLuaClasses](http://lua-users.org/wiki/SimpleLuaClasses)


## Features

- classes
- constructors
- destructors
- inheritance
- instanceof
- parent method calls


## Requirements

- Lua 5.1 or newer


## Installation

Using LuaRocks:

    luarocks install object-model


## Module method overview

- `class([parentClass]): table`
    - create a new class, optionally inheriting methods and properties of another one
- `instanceof(object, class): boolean`
    - check if the given object is an instance of the given class or has that class as
      one of its parents
- `new(class, ...): object`
    - create an instance of the given class and invoke its constructor
    - any additional arguments will be passed to the constructor
    - should not be used directly, invoke the class table instead (refer to the *Instantiating a class* section)
- `super(object, methodName, ...): mixed`
    - invokes a parent method
    - this is the default implementation of `object:super(method, ...)`


## Feature documentation

Let's assume you have imported the `ObjectModel` module like this:

    local o = require 'ObjectModel'


### Creating a new class

The class function returns a new table that you can populate with your methods
and properties.

    MyClass = o.class()


### Inheritance

If another class is passed  to the `class()` function, all of its methods
and properties are inherited.

    MyClass = o.class(OtherClass)

Internally, a shallow copy of the parent class is created for performance reasons.
Therefore modifications of the parent class at a later point will NOT be propagated
to the child classes.


### Prototype properties

Prototype properties are available in all instances of the class.

    MyClass.foo = 'bar'

**Warning!** Do not put tables into prototype properties, unless you want the table
to be shared across all the instances. If you need to initialize a table property
per-instance, do so in the constructor.


### Static properties

There is no separate namespace for static properties. All prototype properties are
defined in the class table, therefore can be accessed without instantiating the class.

    MyClass.staticFoo = 'bar'

    print(MyClass.staticFoo) -- prints: bar


### Methods

Methods are defined the same way as prototype properties.

    MyClass.doSomething = function(self)
        -- do something, self points to the instance
    end

However, one can take advantage of Lua's syntactic sugar to make method definitions prettier:

    function MyClass:doSomething()
        -- do something, self points to the instance
	end


### Static methods

All methods are defined in the class table (same as prototype properties), therefore can be
accessed and called without instantiating the class.

    function MyClass:doSomethingStatic()
        -- self points to MyClass
    end

    MyClass:doSomethingStatic() -- calling a static method


### Constructors

Constructor is a special method that is invoked when a class is being instantiated.

    function MyClass:constructor(arg)
        -- self points to the instance
        -- arg is the first argument passed to the constructor, and so on
    end


### Destructors

Destructor is a special method that is invoked when an instance is being garbage-collected
by Lua.

    function MyClass:destructor()
        -- self points to the instance
        -- no arguments are passed
	end


### Instantiating a class

To create an instance of a class, simply call the class table as a function.

    local obj = MyClass('something')

All arguments passed to this function are forwarded to the constructor.


### Instanceof

To check whether an object is instance of a specific class or has that class as one of its parents, use the `instanceof()` function.

    local obj = MyClass()

    if o.instanceof(obj, MyClass) then
        print('obj is instance of MyClass')
    end


### Calling parent methods

If a class has inherited from another and overridden some of its methods, these methods can be
invoked using the `:super(methodName, ...)` method.

    BaseClass = o.class()

    function BaseClass:constructor(foo)
        self.foo = foo
    end

    DerivedClass = o.class(BaseClass)

    function DerivedClass:constructor(foo, bar)
        self:super('constructor', foo) -- invoke the parent constructor
        self.bar = bar
    end

    local obj = DerivedClass('hello', 'world')

    print(obj.foo, obj.bar) -- prints: hello world


### Metamethods

A class is actually a metatable of its instances. This allows metamethods to be defined the same
way as any other methods.

    function MyClass:__tostring()
        return 'stringified!'
    end

    local obj = MyClass()

    print(obj) -- prints: stringified!
