
Begin;

--Evitar llaves duplicadas al insertar datos nuevos
select setval(pg_get_serial_sequence('prestamo', 'id_prestamo'), coalesce((select MAX(id_prestamo) from prestamo), 1));
select setval(pg_get_serial_sequence('ejemplar', 'id_ejemplar'), coalesce((select MAX(id_ejemplar) from ejemplar), 1));
select setval(pg_get_serial_sequence('socio', 'id_socio'), coalesce((select MAX(id_socio) from socio), 1));
select setval(pg_get_serial_sequence('multa', 'id_multa'), coalesce((select MAX(id_multa) from multa), 1));

commit;
----------------------------------------------------------------------
--actualizar fecha limite prestamo
begin;
create or replace function fn_actualizar_limite_prestamo()
returns trigger as $$
begin 
	if new.fecha_prestamo is null then
		new.fecha_prestamo := current_date;
	end if;
	new.fecha_limite := new.fecha_prestamo + 7;
	return new;
end;
$$ language plpgsql;

create trigger trg_actualizar_limite_prestamo
before insert on prestamo
for each row
execute function fn_actualizar_limite_prestamo();
commit;
----------------------------------------------------------------------
--calcular multa
begin;
create or replace procedure sp_calcular_multas(p_id_tarifa bigint)
language plpgsql
as $$
begin 
	update prestamo
	set estado_prestamo = 'Vencido'
	where fecha_limite < current_date and estado_prestamo = 'Prestado';
	insert into multa(id_prestamo, id_tarifa, dias_retraso, monto_total)
	select
	p.id_prestamo,
	p_id_tarifa,
	(current_date - p.fecha_limite) as dias_retraso,((current_date - p.fecha_limite) * t.precio_por_dia) as monto_total
	from prestamo p
	join tarifa_multa t on t.id_tarifa = p_id_tarifa
	where p.estado_prestamo = 'Vencido'
		and p.fecha_limite < current_date
		and not exists(select 1 from multa m where m.id_prestamo = p.id_prestamo);
end;
$$;
commit;
------------------------------------------------------------------------------
---reserva de libro con validacion disponibilidad
begin;
create or replace procedure sp_reserva_libro(
	p_id_ejemplar bigint,
	p_id_socio bigint,
	p_id_empleado bigint
)
language plpgsql
as $$
declare 
	v_estado_ejemplar varchar;
begin
	select estado into v_estado_ejemplar
	from ejemplar
	where id_ejemplar = p_id_ejemplar;
	if v_estado_ejemplar = 'Disponible' then
		insert into prestamo(id_ejemplar, id_socio, id_empleado_prestamo, fecha_prestamo, fecha_limite, estado_prestamo)
		values(p_id_ejemplar, p_id_socio, p_id_empleado, current_date, current_date + 7, 'Prestado');
		update ejemplar
		set estado = 'Reservado'
		where id_ejemplar = p_id_ejemplar;
		raise notice 'Libro reservado con éxito';
	else
		raise exception 'EL ejemplar % no esta disponible (estado actual: %)', p_id_ejemplar, v_estado_ejemplar;
	end if;
end;
$$;
commit;
--------------------------------------------------------------------------------
--actualizar estado prestamo
begin;
create or replace function fn_actualiza_estado_prestamo()
returns trigger 
as $$
begin
    if new.estado_prestamo = 'Devuelto' and old.estado_prestamo <> 'Devuelto' then
        update ejemplar
        set estado = 'Disponible'
        where id_ejemplar = new.id_ejemplar;
    end if;
    IF new.estado_prestamo = 'Vencido' and old.estado_prestamo <> 'Vencido' then
        update ejemplar
        set estado = 'Reservado'
        where id_ejemplar = new.id_ejemplar;
    end if;
    return new;
end;
$$ language plpgsql;

create trigger trg_actualiza_estado_prestamo
after update on prestamo
for each row
execute function fn_actualiza_estado_prestamo();
commit;
------------------------------------------------------------------------------------------
--actualizar estado multa
begin;
create or replace function fn_actualiza_estado_multa()
returns trigger 
as $$
begin
    if new.estado_pago = 'Pagada' and old.estado_pago <> 'Pagada' then
        update Prestamo
        set estado_prestamo = 'Devuelto',
            fecha_devolucion = current_date
        where id_prestamo = new.id_prestamo;
    end if;
    return new;
end;
$$ language plpgsql;

create trigger trg_actualiza_estado_multa
after update on multa
for each row
execute function fn_actualiza_estado_multa();
commit;
------------------------------------------------------------------------------------------
--libros por categoria
begin;
create or replace function fn_consulta_categoria(p_nombre_categoria varchar)
returns table (
isbn_libro varchar,
titulo_libro varchar
)			
language plpgsql
as $$
begin
return query
	select l.isbn, l.titulo
	from libro l
	inner join categoria c on l.id_categoria = c.id_categoria
	WHERE c.nombre_categoria = p_nombre_categoria;
	end;
$$;
commit;
