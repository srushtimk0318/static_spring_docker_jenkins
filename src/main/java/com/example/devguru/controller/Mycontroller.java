package com.example.devguru.controller;

import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.GetMapping;

@Controller
public class Mycontroller {
    
   @GetMapping("/")
    public String LoadSite() {
        return "Site.html";
    }
}