--       BASE DE DATOS PARA LA GESTIÓN DE UNA BIBLIOTECA

-- CREACIÓN DE LA BASE DE DATOS
create database GestionBiblioteca;

--Conexion a la BASE DE DATOS
\c gestionbiblioteca

-- SECCIÓN 1: TABLAS BÁSICAS (DATOS QUE NO DEPENDEN DE OTRAS TABLAS)


-- 1. EDITORIAL: Guarda las empresas que publican los libros
create table Editorial (
    id_editorial bigint generated always as identity primary key,
    nombre varchar(100) not null unique,
    pais varchar(60) not null
);


-- 2. CATEGORIA: Los temas de los libros (ej. Terror, Romance, Historia)
create table Categoria (
    id_categoria bigint generated always as identity primary key,
    nombre_categoria varchar(80) not null unique
);


-- 3. AUTOR: Los escritores de los libros
create table Autor (
    id_autor bigint generated always as identity primary key,
    nombre varchar(100) not null,
    nacionalidad varchar(60)
);


-- 4. SOCIO: Las personas inscritas en la biblioteca para pedir libros
create table Socio (
    id_socio bigint generated always as identity primary key,
    nombre varchar(80) not null,
    apellido varchar(80) not null,
    email varchar(120) not null unique,
    telefono varchar(20) not null,
    estado varchar(20) not null default 'Activo' -- Estado Activo por defecto
    
    -- Solo permite que el socio esté en uno de estos dos estados
    check (estado in ('Activo', 'Inactivo'))
);


-- 5. EMPLEADO: Los trabajadores de la biblioteca
create table Empleado (
    id_empleado bigint generated always as identity primary key,
    nombre varchar(100) not null,
    cargo varchar(60) not null
);


-- 6. TARIFA_MULTA: Cuánto se cobra por cada día de retraso
create table Tarifa_multa (
    id_tarifa bigint generated always as identity primary key,
    descripcion varchar(100) not null, 
    
    -- Evita que se pongan precios negativos
    precio_por_dia numeric(6,2) not null check (precio_por_dia >= 0)
);


-- SECCIÓN 2: TABLAS DE INFORMACIÓN DE LIBROS


-- 7. LIBRO: Los datos generales de cada libro
create table Libro (
    ISBN varchar(20) primary key,
    titulo varchar(200) not null,
    anio_publicacion int not null,
    id_editorial bigint not null,
    id_categoria bigint not null,
    constraint fk_libro_editorial foreign key (id_editorial)
        references Editorial(id_editorial) on delete restrict on update cascade,
    constraint fk_libro_categoria foreign key (id_categoria)
        references Categoria(id_categoria) on delete restrict on update cascade,
        
    -- Verifica que el año del libro esté en un rango lógico
	constraint chk_anio_valido check (anio_publicacion >= 1400 and
	(anio_publicacion - extract(year from CURRENT_DATE)) <= 0) -- resta el año que escribe el usuario menos el año actual 
												  			   -- obligando a que el resultado sea menor o igual a cero.
); 


-- 8. EJEMPLAR: Los libros físicos reales que están en la biblioteca
-- (Un mismo "Libro" puede tener varios "Ejemplares" físicos en la biblioteca)
create table Ejemplar (
    id_ejemplar bigint generated always as identity primary key,
    ISBN varchar(20) not null,
    estado varchar(30) not null default 'Disponible',
    
    -- Solo permite que el libro físico esté en uno de estos dos estados
    check (estado in ('Disponible', 'Reservado')),
    constraint fk_ejemplar_libro foreign key (ISBN)
        references Libro(ISBN) on delete restrict
);


-- SECCIÓN 3: TABLAS DE OPERACIONES (LO QUE PASA EN LA BIBLIOTECA)


-- 9. LIBRO_AUTOR: Une los libros con sus autores
-- Sirve porque un libro puede tener varios autores y un autor puede escribir varios libros
create table Libro_autor (
    id_autor bigint not null,
    ISBN varchar(20) not null,
    primary key (id_autor, ISBN),
    
	-- Si se borra un autor o un libro, se borra automáticamente su unión aquí:
    constraint fk_la_autor foreign key (id_autor)
        references Autor(id_autor) on delete cascade,
    constraint fk_la_libro foreign key (ISBN)
        references Libro(ISBN) on delete cascade
);


-- 10. PRESTAMO: Controla cuándo se lleva un libro un socio y cuándo lo devuelve
create table Prestamo (
    id_prestamo bigint generated always as identity primary key,
    id_ejemplar bigint not null,
    id_socio bigint not null,
    id_empleado_prestamo bigint not null, -- Empleado que entrega el libro
    fecha_prestamo date not null,
    fecha_limite date not null,
    
    -- Campos de Devolución (empiezan como NULL hasta se devuelva el libro)
    fecha_devolucion date null,
    id_empleado_devolucion bigint null, -- Empleado que recibe el libro
    estado_prestamo varchar(20) not null default 'Prestado'
    -- Solo permite que el prestamo esté en uno de estos tres estados
    check (estado_prestamo in ('Prestado', 'Devuelto', 'Vencido')), 
    
    
    constraint fk_prestamo_ejemplar foreign key (id_ejemplar)
        references Ejemplar(id_ejemplar) on delete restrict,
    constraint fk_prestamo_socio foreign key (id_socio)
        references Socio(id_socio) on delete restrict,
    constraint fk_prestamo_emp_pres foreign key (id_empleado_prestamo)
        references Empleado(id_empleado) on delete restrict,
    constraint fk_prestamo_emp_dev foreign key (id_empleado_devolucion)
        references Empleado(id_empleado) on delete restrict,
        
    -- Reglas para evitar errores en las fechas escritas
    constraint chk_fechas_prestamo
        check (fecha_limite >= fecha_prestamo),
    constraint chk_fechas_devolucion
        check (fecha_devolucion is null or fecha_devolucion >= fecha_prestamo)
);


-- 11. MULTA: Registra los cobros a los socios que devolvieron los libros tarde
create table Multa (
    id_multa bigint generated always as identity primary key,
    id_prestamo bigint not null unique,
    id_tarifa bigint not null, 
    dias_retraso int not null,
    monto_total numeric(8,2) not null, 
    estado_pago varchar(20) not null default 'Pendiente',
                            
    constraint fk_multa_prestamo foreign key (id_prestamo)
        references Prestamo(id_prestamo) on delete restrict on update cascade,
    constraint fk_multa_tarifa foreign key (id_tarifa)
        references Tarifa_multa(id_tarifa) on delete restrict on update cascade,
        
    -- Reglas de control
    constraint chk_dias_retraso check (dias_retraso > 0), -- Solo hay multa si hay días de retraso reales
    constraint chk_monto_positivo check (monto_total >= 0), -- No se pueden cobrar multas con dinero negativo
    -- Solo permite que la multa esté en uno de estos dos estados
    constraint chk_estado_pago check (estado_pago IN ('Pendiente', 'Pagada'))
);
