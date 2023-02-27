package com.microsoft.azure.spring.apps.sample.event.driven;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.context.annotation.Bean;

import java.util.function.Function;

@SpringBootApplication
public class SampleEventDrivenApplication {

    private static final Logger LOGGER = LoggerFactory.getLogger(SampleEventDrivenApplication.class);

    public static void main(String[] args) {
        new SpringApplication(SampleEventDrivenApplication.class).run(args);
    }

    @Bean
    public Function<String, String> process() {
        return message -> {
            LOGGER.info("Processing message: {}.", message);
            return message.toUpperCase();
        };
    }
}
