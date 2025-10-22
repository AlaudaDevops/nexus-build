package com.mycompany.some;

import org.junit.Assert;

import org.junit.Test;
import org.junit.Ignore;
import org.hamcrest.core.StringContains;

/**
 * Unit test for simple App.
 */
public class SomeTest
{
    /**
     * Rigorous Test :-)
     */
    @Test
    public void shouldReturnHelloWorld()
    {
        Some someObj = new Some();

        Assert.assertThat(someObj.Hello("world"), StringContains.containsString("Hello world"));
    }

    @Test
    public void shouldReturnHelloSomeone()
    {
        Some someObj = new Some();

        Assert.assertThat(someObj.Hello("someone"), StringContains.containsString("Hello someone"));
        // assertTrue( someObj.Hello("world") == "Hello world" );
    }

    @Test
    public void shouldReturnHelloJava()
    {
        Some someObj = new Some();

        Assert.assertThat(someObj.Hello("java"), StringContains.containsString("Hello java"));
        // assertTrue( someObj.Hello("world") == "Hello world" );
    }

    @Test
    public void shouldReturnHelloAbc()
    {
        Some someObj = new Some();

        Assert.assertThat(someObj.Hello("abc!!"), StringContains.containsString("Hello abc!!"));
        // assertTrue( someObj.Hello("world") == "Hello world" );
    }

    @Test
    // @Ignore
    public void shouldReturnHelloSkiped()
    {
        Some someObj = new Some();

        Assert.assertThat(someObj.Hello("skips"), StringContains.containsString("Hello skips"));
        // assertTrue( someObj.Hello("world") == "Hello world" );
    }
}
