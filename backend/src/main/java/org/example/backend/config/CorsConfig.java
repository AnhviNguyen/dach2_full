package org.example.backend.config;

import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.web.cors.CorsConfiguration;
import org.springframework.web.cors.UrlBasedCorsConfigurationSource;
import org.springframework.web.filter.CorsFilter;

import java.util.Arrays;

@Configuration
public class CorsConfig {
    @Bean
    public CorsFilter corsFilter() {
        UrlBasedCorsConfigurationSource source = new UrlBasedCorsConfigurationSource();
        CorsConfiguration config = new CorsConfiguration();
        config.setAllowCredentials(true);
        
        // Cho phép tất cả localhost ports (Flutter Web chạy trên port ngẫu nhiên)
        // Pattern matching cho phép bất kỳ port nào trên localhost
        config.addAllowedOriginPattern("http://localhost:*");
        config.addAllowedOriginPattern("https://localhost:*");
        config.addAllowedOriginPattern("http://127.0.0.1:*");
        config.addAllowedOriginPattern("https://127.0.0.1:*");
        
        // Cho phép các origin cụ thể nếu cần (khi deploy)
        // config.addAllowedOrigin("https://yourdomain.com");
        
        config.addAllowedHeader("*");
        config.addAllowedMethod("*");
        
        // Expose headers nếu cần
        config.setExposedHeaders(Arrays.asList("Authorization", "Content-Type"));
        
        source.registerCorsConfiguration("/**", config);
        return new CorsFilter(source);
    }
}

