
--Prueba de triggers y sp
--insertar prestamo sin fecha limite
begin;
insert into prestamo (id_ejemplar, id_socio, id_empleado_prestamo, estado_prestamo)
values(3, 1, 1, 'Prestado');

select id_prestamo, fecha_prestamo, fecha_limite from prestamo order by id_prestamo desc limit 1;

--Reservar libro
call sp_reserva_libro(3, 1, 1);

select * from prestamo order by id_prestamo desc limit 1;
select id_ejemplar, estado from ejemplar where id_ejemplar = 3;

--Calcular multa
update prestamo set fecha_limite = CURRENT_DATE - 5, estado_prestamo = 'Prestado' where id_prestamo = 1;

--call sp_calcular_multa)(i_multa, id_empleado);
call sp_calcular_multa(1,2);

select id_prestamo, estado_prestamo from prestamo where id_prestamo = 1;
select * from multa where id_multa = 1;

--Consultar libros por categoria
select * from fn_consulta_categoria('Literatura de Terror');

--Prueba general
update multa set estado_pago = 'Pagada' where id_multa = 1;

select id_prestamo, estado_prestamo 
from prestamo 
where id_prestamo = (select id_prestamo from multa where id_multa = 1);

select e.id_ejemplar, e.estado 
from ejemplar e
join prestamo p on e.id_ejemplar = p.id_ejemplar
where p.id_prestamo = (select id_prestamo from multa where id_multa = 1);
rollback;

-- Insertar el préstamo
insert into prestamo (id_ejemplar, id_socio, id_empleado_prestamo, estado_prestamo)
values (3, 1, 1, 'Prestado');

-- update vencido prestamo
UPDATE prestamo
SET fecha_prestamo = CURRENT_DATE - 15,
    fecha_limite = CURRENT_DATE - 5,
    estado_prestamo = 'Prestado'
WHERE id_prestamo = 1;

CALL sp_calcular_multa(1,3);

--id_tarifa
insert into Multa (id_prestamo, id_tarifa, dias_retraso, monto_total, estado_pago)
values (501, 1, 5, 25.00, 'Pendiente');
