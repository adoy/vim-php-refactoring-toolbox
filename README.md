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

## Mappings

    nnoremap <unique> <Leader>rlv :call <SID>PhpRenameLocalVariable()<CR>
    nnoremap <unique> <Leader>rcv :call <SID>PhpRenameClassVariable()<CR>
    nnoremap <unique> <Leader>eu :call <SID>PhpExtractUse()<CR>
    vnoremap <unique> <Leader>ec :call <SID>PhpExtractConst()<CR>
    nnoremap <unique> <Leader>ep :call <SID>PhpExtractClassProperty()<CR>
    vnoremap <unique> <Leader>em :call <SID>PhpExtractMethod()<CR>
    nnoremap <unique> <Leader>np :call <SID>PhpCreateProperty()<CR>
    nnoremap <unique> <Leader>du :call <SID>PhpDetectUnusedUseStatements()<CR>
    vnoremap <unique> <Leader>== :call <SID>PhpAlignAssigns()<CR>

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

`<Leader>ep` in normal mode (More detailed doc sonn)

### Extract Method

`<Leader>em` in visual mode (More detailed doc soon)

### Create Property

`<Leader>np` in normal mode (More detailed doc soon)

### Detect unused "use" statements

`<Leader>du` in normal mode (More detailed doc soon)

### Align assignments

`<Leader>==` in visual mode (More detailed doc soon)
