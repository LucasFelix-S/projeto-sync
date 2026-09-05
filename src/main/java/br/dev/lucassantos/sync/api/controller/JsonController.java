package br.dev.lucassantos.sync.api.controller;

import br.dev.lucassantos.sync.domain.dto.JsonRequestDTO;
import br.dev.lucassantos.sync.domain.service.JsonService;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/integracao/json")
public class JsonController {

    private final JsonService jsonService;

    public JsonController(JsonService jsonService) {
        this.jsonService = jsonService;
    }

    @PostMapping
    public ResponseEntity<Void> inserir(@RequestBody JsonRequestDTO jsonRequestDTO) {
        jsonService.inserir(jsonRequestDTO);
        return ResponseEntity.ok().build();
    }

}