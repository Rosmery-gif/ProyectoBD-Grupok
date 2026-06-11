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