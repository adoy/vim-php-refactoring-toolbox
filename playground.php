<?php

namespace AdoY\PHP\Refactoring\Toolbox;

use I\Am\Really\Useless as NobodyLovesMe;
use I\Am\Usefull as Lover;

class Playground
{
    private $renameMe = 10;

    /**
     * Place your cursor on a local variable and press <Leader>rlv
     * to rename a function local variable
     */
    public function testRenameLocalVariable($renameMe)
    {
        $renameMe = 'renameMe will be renamed';
        $renameMeAlso = $renameMe;
        $this->renameMe = 'If will be renamed in the next test';
    }

    /**
     * Place your cursor on a class variable and press <Leader>rcv
     * to rename a property (class variable)
     */
    public function testRenameClassVariable($renameMe)
    {
        $this->renameMe = 'RenameMe rename every usage of this property in the current class';
        $renameMe = 'I\'m not renamed';
    }

    /**
     * Place your cursor on a Fully qualified class name and press <Leader>eu
     * to create an alias and place the new Use statement on top of the file
     */
    public function testExtractUse(\Fully\Qualified\Classname $obj)
    {
        if (!$obj instanceof \Fully\Qualified\Classname) {
            Throw new Exception('$obj is not a \Fully\Qualified\Classname');
        }
        return new \Fully\Qualified\AnOtherClassname;
    }

    /**
     * Select the content you want to place in the content with the visual mode
     * (you could use viw on int or va' on string)
     * and then press <Leader>ec to create a constant and replace every occurence of this
     * by the constant usage
     */
    public function testExtractConst()
    {
        $dix = 1001;
        $string = 'FOOBAR';
    }

    /**
     * Place your cursor on the "localVariableWanabeAClassVariable" variable
     * and press <Leader>ep to promote this variable as class property
     */
    public function testExtractClassProperty($newval)
    {
        $localVariableWanabeAClassVariable = $newval;
    }

    /**
     * Select different block of code and extract it to different methods using
     * <Leader>em
     */
    public function testExtractMethod($message)
    {
        // Make a very cool wave with the message
        for ($i = 0; $i < strlen($message); $i++) {
            $message[$i] = $i % 2 ? strtoupper($message[$i]) : strtolower($message[$i]);
        }

        // Put the message in a fancy box
        $borderTopAndBottom = '+' . str_repeat('=', strlen($message)+2) . '+';
        $newMessage = $borderTopAndBottom . PHP_EOL;
        $newMessage .= '| ' . $message . ' |' . PHP_EOL;
        $newMessage .= $borderTopAndBottom . PHP_EOL;

        return $newMessage;
    }

    /**
     * Press <Leader>np to create a property
     */
    public function testCreateNewProperty()
    {
        $this->notCreated;
    }

    /**
     * Press <Leader>du to detect unused use statements
     */
    public function testDetectUnusedStatements()
    {
        new Lover;
    }

    /**
     * Select the inner function block
     * and press <Leader>== to align all assignements
     */
    public function testAlignAssigns()
    {
        $oneVar = 'Foo';
        $anOtherVar = 'Bar';
        $oneVar += 'Baz';
    }

}
