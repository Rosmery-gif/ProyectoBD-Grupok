
-- 1. editorial
copy editorial (id_editorial, nombre, pais)
from 'C:\temp\EDITORIAL.csv'
with (format csv, header, delimiter ',', null '');

-- 2. Categoria
copy categoria (id_categoria, nombre_categoria)
from 'C:\temp\CATEGORIA_DATA.csv'
with (format csv, header, delimiter ',', null '');

-- 3. Autor
copy autor (id_autor, nombre, apellido, nacionalidad)
from 'C:\temp\AUTOR_DATA.csv'
with (format csv, header, delimiter ',', null '');


-- 4. socio
copy socio (id_socio, nombres, apellido, email, telefono, estado)
from 'C:\temp\SOCIO_DATA.csv'
with (format csv, header, delimiter ',', null '');


-- 5. empleado
copy empleado (id_empleado, nombre, cargo)
from 'C:\temp\EMPLEADO_DATA.csv'
with (format csv, header, delimiter ',', null '');

-- 6. tarifa_multa
copy tarifa_multa (id_tarifa, descripcion, precio_por_dia)
from 'C:\temp\TARIFA_MULTA_DATA.csv'
with (format csv, header, delimiter ',', null '');

-- 7. libro
copy libro (isbn, titulo, anio_publicacion, id_editorial, id_categoria)
from 'C:\temp\LIBRO.csv'
with (format csv, header, delimiter ',', null '');

-- 8. ejemplar
copy ejemplar (id_ejemplar, isbn, estado)
from 'C:\Users\DELL\Downloads\EJEMPLAR.csv'
with (format csv, header, delimiter ',', null '');

-- 9. libro_autor
copy libro_autor ( id_autor, isbn)
from 'C:\Users\DELL\Downloads\LIBRO_AUTOR_NUEVO.csv'
with (format csv, header, delimiter ',', null '');

-- 10. prestamo
copy prestamo (
    id_prestamo,
    id_ejemplar,
    id_socio,
    id_empleado_prestamo,
    fecha_prestamo,
    estado_prestamo,
    fecha_limite,
    fecha_devolucion,
    id_empleado_devolucion
)
from 'C:\temp\PRESTAMO_DATA.csv'
with (format csv, header, delimiter ',', null '');

-- 11. multa
copy multa (
    id_multa,
    id_prestamo,
    id_tarifa,
    dias_retraso,
    monto_total,
    estado_pago
)
from 'C:\temp\MULTA_DATA.csv'
with (format csv, header, delimiter ',', null '');


