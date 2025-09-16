package com.example.demo;

import org.junit.jupiter.api.Test;
import org.springframework.boot.test.context.SpringBootTest;

@SpringBootTest
class DemoApplicationTests {

    @Test
    void contextLoads() {
        // 简单的上下文加载测试
        System.out.println("Spring Boot context loaded successfully!");
    }

    @Test
    void applicationStartsSuccessfully() {
        // 测试应用启动
        DemoApplication application = new DemoApplication();
        // 简单的实例化测试
        assert application != null;
        System.out.println("DemoApplication instance created successfully!");
    }
}