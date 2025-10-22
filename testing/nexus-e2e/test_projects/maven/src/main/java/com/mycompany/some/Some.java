package com.mycompany.some;

/**
 * Hello world!
 *
 */
public class Some
{
    public String Hello( String name) {
        if (name == "SURPRISE" ) {
            return "SURPRISE SURPRISE";
        }
        if (name == "BATMAN") {
            return "NaNaNaNaNaNaNaNaNaNaNaNa, BATMAN!";
        }

        return "Hello "+name;
    }
}
