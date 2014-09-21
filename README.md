# VIM Php Refactoring Toolbox

PHP Refactoring Toolbox for VIM

* Rename Local Variable
* Rename Class Variable
* Extract Use
* Extract Const
* Extract Class Property
* Extract Method
* Create Property
* Detect Unused Use Statements
* Align Assigns
* Create setters and getters
* Document all code

## Installation 

Copy the `php-refactoring-toolbox.vim` in your `~/.vim/plugin` folder.

If you want to disable the default mapping just add this line in your `~/.vimrc` file 

```
let g:vim_php_refactoring_use_default_mapping = 0
```

## Default Mappings

    nnoremap <unique> <Leader>rlv :call PhpRenameLocalVariable()<CR>
    nnoremap <unique> <Leader>rcv :call PhpRenameClassVariable()<CR>
    nnoremap <unique> <Leader>rm :call PhpRenameMethod()<CR>
    nnoremap <unique> <Leader>eu :call PhpExtractUse()<CR>
    vnoremap <unique> <Leader>ec :call PhpExtractConst()<CR>
    nnoremap <unique> <Leader>ep :call PhpExtractClassProperty()<CR>
    vnoremap <unique> <Leader>em :call PhpExtractMethod()<CR>
    nnoremap <unique> <Leader>np :call PhpCreateProperty()<CR>
    nnoremap <unique> <Leader>du :call PhpDetectUnusedUseStatements()<CR>
    vnoremap <unique> <Leader>== :call PhpAlignAssigns()<CR>
    nnoremap <unique> <Leader>sg :call PhpCreateSettersAndGetters()<CR>
    nnoremap <unique> <Leader>da :call PhpDocAll()<CR>

## Playground.php

You'll find in this project a `playground.php` file. You can use this file to start playing with this refactoring plugin.

## Examples

↑ Is the position of your cursor

### Rename Local Variable

``` php
<?php
function helloWorld($foobar = null) {
    echo "Hello " . $foobar;
}                      ↑
```

`<Leader>rlv` in normal mode, specify the new `$name`

``` php
<?php
function helloWorld($name = null) {
    echo "Hello " . $name;
}                      ↑
```

### Rename Class Variable

``` php
<?php
class HelloWorld {
    private $foobar;
    public function __construct($name) {
        $this->foobar = $name;
    }
    public function sayHello() {
        echo $this->foobar;
    }                 ↑
}
```

`<Leader>rcv` in normal mode, specify the new `$name`

``` php
<?php
class HelloWorld {
    private $name;
    public function __construct($name) {
        $this->name = $name;
    }
    public function sayHello() {
        echo $this->name;
    }
}
```

### Extract Use Statement

``` php
<?php
$obj1 = new Foo\Bar\Baz;
$obj2 = new Foo\Bar\Baz;
                 ↑
```

`<Leader>eu` in normal mode

``` php
<?php

use Foo\Bar\Baz;

$obj1 = Baz;
$obj2 = Baz;
```

### Extract Class Property

``` php
<?php

class Dir {
    public function __construct($path) {
        $realpath = $path;
    }       ↑
}
```

`<Leader>ep` in normal mode will extract the local variable and create a property inside the current class.

``` php
<?php

class Dir {
    private $realpath;
    public function __construct($path) {
        $this->realpath = $path;
    }       ↑
}
```

### Extract Method

``` php
<?php

class HelloWorld {
    public function sayHello($firstName = null) {
        $sentence = 'Hello';                  
        if ($firstName) {                     
            $sentence .= ' ' . $firstName;
        }
        echo $sentence;
    }
}
```

Select in visual mode (V) the code you want to extract in an other method and hit `<Leader>em`.
You'll be prompted for a method name. Enter a method name and press enter

``` php
<?php

class HelloWorld {
    public function sayHello($firstName = null) {
        $sentence = $this->prepareSentence($firstName);
        echo $sentence;
    }

    private function prepareSentence($firstName)
    {
        $sentence = 'Hello';                
        if ($firstName) {
            $sentence .= ' ' . $firstName;
        }
        return $sentence;
    }
}
```

### Create Property

`<Leader>np` will create a new property in your current class.

### Detect unused "use" statements

`<Leader>du` will detect all unused "use" statements in your code so that you can remove them.

### Align assignments

``` php
<?php

$oneVar = 'Foo';
$anOtherVar = 'Bar';
$oneVar += 'Baz';
```

Select the code you want to align and then hit `<Leader>==`

``` php
<?php

$oneVar     =  'Foo';
$anOtherVar =  'Bar';
$oneVar     += 'Baz';
```

### Create setters and getters

``` php
<?php

class Foo {
    private $bar;
}
```

Hit `<Leader>sg` and you'll be prompted if you want to create setters and getters for existing properties.

``` php
<?php

class Foo {
    private $bar;

    public function setBar($bar)
    {
        $this->bar = $bar;
    }

    public function getBar()
    {
        return $this->bar;
    }
}
```

### Document all

`<Leader>da` will call your documentation plugin (by default Php Documentor for vim https://github.com/tobyS/pdv) for every uncommented classes, methods, functions and properties.


