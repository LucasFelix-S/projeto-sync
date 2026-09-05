package br.dev.lucassantos.sync.domain.service;

import br.dev.lucassantos.sync.domain.dto.JsonRequestDTO;
import br.dev.lucassantos.sync.domain.model.JsonEntity;
import br.dev.lucassantos.sync.domain.repository.JsonRepository;
import org.springframework.stereotype.Service;

@Service
public class JsonService {
    private final JsonRepository jsonRepository;

    public JsonService(JsonRepository jsonRepository) {
        this.jsonRepository = jsonRepository;
    }

    public void inserir (JsonRequestDTO jsonRequestDTO){

        JsonEntity jsonEntity = new JsonEntity();
        jsonEntity.setConteudo(jsonRequestDTO.conteudo());
        jsonEntity.setTipo(jsonRequestDTO.tipo());

        jsonRepository.save(jsonEntity);
    }

}
