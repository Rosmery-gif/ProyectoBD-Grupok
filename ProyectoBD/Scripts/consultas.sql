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
select s.nombre ||' '|| s.apellido nombre_socio , m.dias_retraso, m.monto_total  
from multa m 
join prestamo p on m.id_prestamo = p.id_prestamo
join socio s on p.id_socio = s.id_socio
where m.estado_pago = 'Pendiente'
order by dias_retraso;

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
