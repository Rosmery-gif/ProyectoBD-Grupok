--Consultas sugeridas

--Top 20 libros más prestados los últimos 3 meses
select l.titulo, count(p.id_ejemplar ) veces_prestado
from prestamo p 
join ejemplar e on p.id_ejemplar = e.id_ejemplar
join libro l on e.isbn = l.isbn
where current_date - p.fecha_prestamo <= 90
group by l.titulo
order by veces_prestado desc
limit 20;

--Socios con multas pendientes
select p.id_prestamo , s.nombre ||' '|| s.apellido nombre_socio , m.dias_retraso, m.monto_total  
from multa m 
join prestamo p on m.id_prestamo = p.id_prestamo
join socio s on p.id_socio = s.id_socio
where m.estado_pago = 'Pendiente'
order by dias_retraso desc
limit 10 offset 20; --Muestra la 3 pag

--Autores con mayor número de títulos en catálogo
select a.id_autor  , a.nombre, count(*) numero_titulos
from libro l 
join libro_autor la on l.isbn = la.isbn
join autor a on la.id_autor = a.id_autor
group by a.nombre, a.id_autor 
order by numero_titulos desc
limit 10;

--Ejemplares que nunca han sido prestados
select e.id_ejemplar , l.titulo 
from ejemplar e 
join libro l on e.isbn = l.isbn
left join prestamo p on e.id_ejemplar = p.id_ejemplar 
where p.id_ejemplar is null;

--Empleado que ha procesado más prestamos en el mes
select e.id_empleado , e.nombre , count(p.id_prestamo ) prestamos
from empleado e 
join prestamo p on e.id_empleado = p.id_empleado_prestamo
where extract(month from p.fecha_prestamo ) = extract(month from current_date)
and extract(year from p.fecha_prestamo ) = extract(year from current_date)
group by e.id_empleado, e.nombre 
order by prestamos  desc 
limit 1;

--Consultas inventadas

--Socios con más libros prestados
select s.id_socio , s.nombre  || ' ' || s.apellido nombre_socio, count (p.id_prestamo ) libros_prestados
from socio s 
join prestamo p on s.id_socio = p.id_socio
where p.estado_prestamo = 'Prestado'
group by s.id_socio, s.nombre , s.apellido 
order by libros_prestados desc
limit 10;

--Categoría con más ejemplares
select c.nombre_categoria , count(e.id_ejemplar ) total_ejemplares
from libro l 
join categoria c on l.id_categoria = c.id_categoria
join ejemplar e on l.isbn = e.isbn 
group by c.nombre_categoria
order by total_ejemplares desc 
limit 3;

--Estado de libros en stock
select l.titulo ,
case 
	when count(e.id_ejemplar) >= 10 then 'Titulo bien abastecido'
	when count(e.id_ejemplar) between 7 and 9 then 'Titulo abastecido'
	when count(e.id_ejemplar) between 4 and 6 then 'Titulo poco abastecido'
	else 'Titulo muy poco abastecido'
end estado_stock , count(e.id_ejemplar ) cantidad_ejemplares
from libro l 
join ejemplar e on l.isbn = e.isbn
group by l.titulo 
order by cantidad_ejemplares desc;

--Socios que más tiempo han tenido un libro
select s.nombre || ' ' || s.apellido nombre_socio, p.fecha_prestamo , p.fecha_devolucion ,
p.fecha_devolucion - p.fecha_prestamo dias_posecion 
from prestamo p 
join socio s on p.id_socio = s.id_socio
where p.estado_prestamo = 'Devuelto'
order by dias_posecion desc
limit 10;

--Clasificación de devoluciones de este año
select p.id_prestamo , s.nombre || ' ' || s.apellido nombre_socio, extract(month from p.fecha_devolucion) mes_devuelto,
case
	when p.fecha_devolucion <= p.fecha_limite then 'Entregado a tiempo'
	when p.fecha_devolucion - p.fecha_limite between 1 and 5 then 'Retraso leve'
	when p.fecha_devolucion - p.fecha_limite between 6 and 9 then 'Retraso moderado'
	else 'Retraso grave'
end tipo_retraso
from prestamo p 
join socio s on p.id_socio = s.id_socio
where p.fecha_devolucion is not null
order by 
case 
	when p.fecha_devolucion <= p.fecha_limite then 1
	when p.fecha_devolucion - p.fecha_limite between 1 and 5 then 2
	when p.fecha_devolucion - p.fecha_limite between 6 and 9 then 3
	else 4
end;