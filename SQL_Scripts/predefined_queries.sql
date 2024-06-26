-- 1) Listar o nome e a cidade das escolas onde todos os alunos residam na mesma cidade onde a escola está localizada.

SELECT 
    e.nome AS nome_escola,
    c.nome AS cidade_escola
FROM 
    escola e
JOIN 
    cidade c ON e.codigo_cidade = c.codigo
WHERE NOT EXISTS ( -- verificar se há uma linha que a condição é verdadeira, se houver retorna false
    SELECT 
        1 -- Select 1 é apenas uma forma eficiente de ocupar uma linha
    FROM 
        turma t
    JOIN 
        aluno a ON t.codigo = a.codigo_turma
    JOIN 
        pessoa p ON a.codigo = p.codigo
    WHERE 
        t.codigo_escola = e.codigo and
        p.codigo_cidade != e.codigo_cidade
);


-- 2) Listar o nome e matrícula dos alunos sem nenhum contato cadastrado.

SELECT p.nome, a.matricula_aluno

FROM aluno a

JOIN pessoa p ON a.codigo = p.codigo
LEFT JOIN contato c ON a.codigo = c.codigo_aluno
WHERE c.codigo_aluno IS NULL;


-- 4) Listar o código, nome e titulação dos professores que ministram aulas para pelo menos
--    três turmas diferentes.

SELECT
    prof.codigo AS codigo_professor, p.nome AS nome_professor, prof.titulacao AS titulacao_professor
FROM
    professor prof
JOIN
    pessoa p ON prof.codigo = p.codigo
WHERE
    prof.codigo IN (SELECT prof.codigo
                    FROM professor prof
                    LEFT JOIN dar_aula da ON prof.codigo = da.codigo_professor
                    GROUP BY prof.codigo
                    HAVING COUNT(DISTINCT da.codigo_turma) >= 3);


-- 5) Listar por disciplina o número de professores que podem ministrá-la e quantos 
--    efetivamente ministram a mesma para uma turma.

SELECT
    m.codigo_disciplina,
    COUNT(DISTINCT da.codigo_professor) AS professores_efetivos,
    COUNT(DISTINCT m.codigo_professor) AS possiveis_professores
FROM
    ministra m
LEFT JOIN
    dar_aula da ON m.codigo_professor = da.codigo_professor
GROUP BY
    m.codigo_disciplina;


-- 7) Listar por escola o número de turmas e o número de professores que ministram alguma 
--    disciplina para turmas da escola em questão.

SELECT 
    e.nome AS nome_escola,
    COUNT(DISTINCT t.codigo) AS numero_turmas,
    COUNT(DISTINCT da.codigo_professor) AS numero_professores
    
FROM 
    escola e
    
LEFT JOIN 
    turma t ON e.codigo = t.codigo_escola -- dado uma turma em uma escola
LEFT JOIN 
    dar_aula da ON t.codigo = da.codigo_turma --
GROUP BY 
    e.codigo, e.nome;
    
    
-- 8) Listar por escola a razão entre o número de alunos da escola e o número de professores
--    que ministram alguma disciplina na escola em questão.

SELECT 
    e.nome AS nome_escola,
    -- COALESCE(COUNT(DISTINCT a.codigo), 0) AS numero_alunos, (teste para verificar se a contagem de alunos está correta)
    -- COALESCE(COUNT(DISTINCT da.codigo_professor), 0) AS numero_professores, (teste para verificar se a contagem de professores está correta)
    COALESCE(COUNT(DISTINCT a.codigo) / NULLIF(COUNT(DISTINCT da.codigo_professor), 0), 0) AS razao_alunos_professores
FROM 
    escola e
LEFT JOIN 
    turma t ON e.codigo = t.codigo_escola
LEFT JOIN 
    aluno a ON t.codigo = a.codigo_turma
LEFT JOIN 
    dar_aula da ON t.codigo = da.codigo_turma
GROUP BY 
    e.codigo, e.nome;


-- 9)Listar todos os contatos dos alunos informando a matrícula e nome do aluno, nome e
--   telefone do contato, ordenado por matrícula do aluno e nome do contato.

SELECT a.matricula_aluno, p.nome, c.nome AS nome_contato, c.telefone AS telefone_contato
FROM
	pessoa p
JOIN
	aluno a ON p.codigo = a.codigo
JOIN
	contato c ON a.codigo = c.codigo_aluno
ORDER BY
	a.matricula_aluno, nome_contato


-- 10) Listar todos os professores que ministram disciplinas para apenas uma turma.

SELECT
    da.codigo_professor
FROM
    dar_aula da
GROUP BY
    da.codigo_professor
HAVING 
    COUNT(DISTINCT da.codigo_turma) == 1;
