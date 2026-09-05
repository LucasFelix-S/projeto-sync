package br.dev.lucassantos.sync.domain.repository;

import br.dev.lucassantos.sync.domain.model.JsonEntity;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

@Repository
public interface JsonRepository extends JpaRepository<JsonEntity, Long> {
}