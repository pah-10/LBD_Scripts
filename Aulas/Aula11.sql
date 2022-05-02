/*
Subconsultas de uma única linha retornam zero ou no máximo 1 linha
Pode ser usada no where, having ou no from
Não podem ser ordenadas
*/

SELECT id_cliente, nome, sobrenome
FROM tb_clientes
WHERE id_cliente = (SELECT id_cliente
                    FROM tb_clientes
                    WHERE sobrenome = 'Blue');
                    
SELECT id_produto, nm_produto, preco
FROM tb_produtos
WHERE preco > (SELECT AVG(preco)
               FROM tb_produtos)
ORDER BY id_produto DESC;

SELECT id_tipo_produto, AVG(preco)
FROM tb_produtos
GROUP BY id_tipo_produto
HAVING AVG(preco) < (SELECT MAX(AVG(preco))
                     FROM tb_produtos
                     GROUP BY id_tipo_produto)
ORDER BY id_tipo_produto;

--subconsultas na clausula FROM são chamadas de visões inline 

SELECT id_produto
FROM (SELECT id_produto
      FROM tb_produtos
      WHERE id_produto < 3);

SELECT p.id_produto, preco, dados_compra.count_produto
FROM tb_produtos p, (SELECT id_produto, COUNT(id_produto) count_produto
                     FROM tb_compras
                     GROUP BY id_produto) dados_compra
WHERE p.id_produto = dados_compra.id_produto;

/*
Subconsultas de várias linhas retornam várias tuplas
Podem ser usadas nos operadores IN, ANY e ALL (pode ser usado o NOT)
*/

SELECT id_produto, nm_produto
FROM tb_produtos
WHERE id_produto IN (1, 2, 3);

SELECT id_produto, nm_produto
FROM tb_produtos
WHERE id_produto IN (SELECT id_produto
                     FROM tb_produtos
                     WHERE nm_produto LIKE '%e%');

SELECT id_produto, nm_produto
FROM tb_produtos
WHERE id_produto NOT IN (SELECT id_produto
                         FROM tb_compras);

SELECT id_funcionario, nome, salario
FROM tb_funcionarios
WHERE salario < ANY(SELECT base_salario
                    FROM tb_grades_salarios);

SELECT id_funcionario, nome, salario
FROM tb_funcionarios
WHERE salario > ALL (SELECT teto_salario
                     FROM tb_grades_salarios);

SELECT id_produto, id_tipo_produto, nm_produto, preco
FROM tb_produtos
WHERE (id_tipo_produto, preco) IN (SELECT id_tipo_produto, MIN(preco)
                                   FROM tb_produtos
                                   GROUP BY id_tipo_produto);

/*
Subconsultas correlacionadas é executada uma vez para cada linha e trabalha com nulos
Pode usar o EXITS ou o NOT EXITS para verificar se existe ou não (EXITS pode ser usados com valores literais tbm)
*/

SELECT id_produto, id_tipo_produto, nm_produto, preco
FROM tb_produtos externa
WHERE preco > (SELECT AVG(preco)
               FROM tb_produtos interna
               WHERE interna.id_tipo_produto = externa.id_tipo_produto);

SELECT id_funcionario, nome, sobrenome
FROM tb_funcionarios externa
WHERE EXISTS (SELECT id_funcionario
              FROM tb_funcionarios interna
              WHERE interna.id_gerente = externa.id_funcionario);

SELECT id_funcionario, nome, sobrenome
FROM tb_funcionarios externa
WHERE EXISTS (SELECT 1
              FROM tb_funcionarios interna
              WHERE interna.id_gerente = externa.id_funcionario);

SELECT id_produto, nm_produto
FROM tb_produtos externa
WHERE NOT EXISTS (SELECT 1
                  FROM tb_compras interna
                  WHERE interna.id_produto = externa.id_produto);

SELECT id_tipo_produto, nm_tipo_produto
FROM tb_tipos_produtos externa
WHERE NOT EXISTS(SELECT 1
                 FROM tb_produtos interna
                 WHERE interna.id_tipo_produto = externa.id_tipo_produto);

SELECT id_tipo_produto, nm_tipo_produto
FROM tb_tipos_produtos 
WHERE id_tipo_produto NOT IN (SELECT id_tipo_produto
                              FROM tb_produtos);
                              
--usa o nvl para fazer o tratamento e retornar corretamente
SELECT id_tipo_produto, nm_tipo_produto
FROM tb_tipos_produtos 
WHERE id_tipo_produto NOT IN (SELECT NVL(id_tipo_produto, 0)
                              FROM tb_produtos);
