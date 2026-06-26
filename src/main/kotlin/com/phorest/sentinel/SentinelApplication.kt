package com.phorest.sentinel

import org.springframework.boot.autoconfigure.SpringBootApplication
import org.springframework.boot.runApplication

@SpringBootApplication
class SentinelApplication

fun main(args: Array<String>) {
	runApplication<SentinelApplication>(*args)
}
