# VIM Php Refactoring Toolbox

PHP Refactoring Toolbox for VIM

* Rename Local Variable
* Rename Class Variable
* Rename Method
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

* [vim-plug](https://github.com/junegunn/vim-plug): `Plug 'adoy/vim-php-refactoring-toolbox'`
* [vundle](https://github.com/gmarik/Vundle.vim): `Plugin 'adoy/vim-php-refactoring-toolbox'`
* [pathogen](https://github.com/tpope/vim-pathogen): `git clone https://github.com/adoy/vim-php-refactoring-toolbox.git ~/.vim/bundle/`
* or just copy the `plugin/php-refactoring-toolbox.vim` in your `~/.vim/plugin` folder


If you want to disable the default mapping just add this line in your `~/.vimrc` file

```
let g:vim_php_refactoring_use_default_mapping = 0
```

If you want to disable the user validation at the getter/setter creation, just add this line in your `~/.vimrc` file

```
let g:vim_php_refactoring_auto_validate_sg = 1
```

If you want to disable the user validation for all rename features, just add this line in your  `~/.vimrc` file

```
let g:vim_php_refactoring_auto_validate_rename = 1
```

If you want to disable the user validation for the visibility (private/public) add this line in your `~/.vimrc` file
```
let g:vim_php_refactoring_auto_validate_visibility = 1
```

To change the default visibility add one/both of those lines in your `~/.vimrc` file
```
let g:vim_php_refactoring_default_property_visibility = 'private'
let g:vim_php_refactoring_default_method_visibility = 'private'
```

To enable fluent setters add either of these lines to your `~/.vimrc` file
```
" default is 0 -- disabled

" to enable for all setters
let g:vim_php_refactoring_fluent_setter = 1

" to enable but be prompted when creating the setter
let g:vim_php_refactoring_fluent_setter = 2
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

### Rename method

``` php
<?php
class HelloWorld {
    public function sayHello() {
        echo $this->sayHello();
    }                 ↑
}
```

`<Leader>rm` in normal mode, specify the new method name

``` php
<?php
class HelloWorld {
    public function newMethodName() {
        echo $this->newMethodName();
    }                 ↑
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

Hit `<Leader>sg` and you'll be prompted if you want to create setters and getters for existing properties and if you want to make the setter fluent.

``` php
<?php

class Foo {
    private $bar;

    public function setBar($bar)
    {
        $this->bar = $bar;

        return $this; // If you opted for a fluent setter at the prompt.
    }

    public function getBar()
    {
        return $this->bar;
    }
}
```

### Document all

`<Leader>da` will call your documentation plugin (by default Php Documentor for vim https://github.com/tobyS/pdv) for every uncommented classes, methods, functions and properties.


