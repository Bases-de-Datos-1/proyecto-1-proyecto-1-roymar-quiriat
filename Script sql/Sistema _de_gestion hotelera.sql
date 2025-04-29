CREATE DATABASE Turismo_Limon;
GO

USE Turismo_Limon;
Go

--Creacion de Tablas 
CREATE TABLE Empresa (
	id_empresa INT IDENTITY(1,1) PRIMARY KEY,
	nombre_empresa VARCHAR(100) NOT NULL,
	cedula_juridica VARCHAR(12) NOT NULL UNIQUE, 
	correo_electronico VARCHAR(100) NOT NULL,
	provincia VARCHAR(10) NOT NULL,
	canton VARCHAR(25) NOT NULL,
	distrito VARCHAR(30) NOT NULL,
	barrio VARCHAR(50) NOT NULL,
	senias_exactas VARCHAR(255) NOT NULL,
	CONSTRAINT CHK_cedula_juridica_formato 
		CHECK (cedula_juridica LIKE 
		'[13]-[0-9][0-9][0-9]-[0-9][0-9][0-9][0-9][0-9][0-9]'),
	CONSTRAINT CHK_empresa_correo_electronico_formato
		CHECK (correo_electronico LIKE '%_@__%.__%')	
); 
GO

CREATE TABLE Hospedaje (
	id_hospedaje INT IDENTITY(1,1) PRIMARY KEY,
	id_empresa INT NOT NULL,
	tipo_hospedaje VARCHAR(50) NOT NULL,
	referencia_gps VARCHAR(100) NULL,
	enlace VARCHAR(255) NULL,
	CONSTRAINT FK_Hospedaje_Empresa FOREIGN KEY (id_empresa)
		REFERENCES Empresa(id_empresa),
	CONSTRAINT CHK_tipo_hospedaje 
		CHECK (tipo_hospedaje IN (
		'Hotel',
		'Casa',
		'Departamento',
		'Cuarto Compartido',
		'Cabaña'
		))
);
GO

CREATE TABLE Hospedaje_Telefono(
	id_telefono INT IDENTITY(1,1) PRIMARY KEY,
	id_hospedaje INT NOT NULL,
	numero_telefonico VARCHAR(8) NOT NULL,
	CONSTRAINT FK_Telefono_Hospedaje FOREIGN KEY (id_hospedaje)
		REFERENCES Hospedaje(id_hospedaje),
	CONSTRAINT CHK_hospedaje_telefono_valor_numerico 
		CHECK (ISNUMERIC(numero_telefonico) = 1)
);
GO

CREATE TABLE Hospedaje_Servicio(
	id_servicio INT IDENTITY(1,1) PRIMARY KEY,
	id_hospedaje INT NOT NULL,
	servicio VARCHAR(100) NOT NULL,
	CONSTRAINT FK_Servicio_Hospedaje FOREIGN KEY (id_hospedaje)
		REFERENCES Hospedaje(id_hospedaje)
);
GO

CREATE TABLE Hospedaje_Red_Social(
	id_red_social INT IDENTITY(1,1) PRIMARY KEY,
	id_hospedaje INT NOT NULL,
	plataforma VARCHAR(20) NOT NULL,
	enlace VARCHAR(100) NOT NULL,
	CONSTRAINT FK_Red_Social_Hospedaje FOREIGN KEY (id_hospedaje)
		REFERENCES Hospedaje(id_hospedaje)
);
GO

CREATE TABLE Tipo_Habitacion(
	id_tipo_habitacion INT IDENTITY(1,1) PRIMARY KEY,
	id_hospedaje INT NOT NULL,
	nombre VARCHAR(30) NOT NULL,
	descripcion VARCHAR(255) NOT NULL,
	tipo_cama VARCHAR(20) NOT NULL,
	precio DECIMAL(10,2) NOT NULL,
	CONSTRAINT FK_Tipo_Habitacion_Hospedaje FOREIGN KEY (id_hospedaje)
		REFERENCES Hospedaje(id_hospedaje)
);
GO

CREATE TABLE Tipo_Habitacion_Comodidad(
	id_comodidad INT IDENTITY(1,1) PRIMARY KEY,
	id_tipo_habitacion INT NOT NULL,
	comodidad VARCHAR(50),
	CONSTRAINT FK_Comodidad_Tipo_Habitacion FOREIGN KEY (id_tipo_habitacion)
		REFERENCES Tipo_Habitacion(id_tipo_habitacion)
);
GO

CREATE TABLE Tipo_Habitacion_Foto(
	id_foto INT IDENTITY(1,1) PRIMARY KEY,
	id_tipo_habitacion INT NOT NULL,
	foto VARBINARY(MAX) NOT NULL,
	CONSTRAINT FK_Foto_Tipo_Habitacion FOREIGN KEY (id_tipo_habitacion)
		REFERENCES Tipo_Habitacion(id_tipo_habitacion)
);
GO

CREATE TABLE Habitacion (
	id_habitacion INT IDENTITY(1,1) PRIMARY KEY,
	id_tipo_habitacion INT NOT NULL,
	numero VARCHAR(10) NOT NULL,
	CONSTRAINT FK_Habitacion_Tipo FOREIGN KEY (id_tipo_habitacion)
		REFERENCES Tipo_Habitacion(id_tipo_habitacion) 
);
GO

CREATE TABLE Cliente(
	id_cliente INT IDENTITY(1,1) PRIMARY KEY,
	nombre VARCHAR(40) NOT NULL,
	primer_apellido VARCHAR(40) NOT NULL,
	segundo_apellido VARCHAR(40) NOT NULL,
	fecha_nacimiento DATE NOT NULL,
	tipo_identificacion VARCHAR(20) NOT NULL,
	numero_identificacion VARCHAR(50) NOT NULL UNIQUE,
	pais_residencia VARCHAR(50) NOT NULL,
	correo_electronico VARCHAR(100) NOT NULL,
	provincia VARCHAR(10) NULL,
	canton VARCHAR(25) NULL,
	distrito VARCHAR(30) NULL,
	CONSTRAINT CHK_cliente_correo_electronico_formato 
		CHECK (correo_electronico LIKE '%_@%__.__%')
);
GO

CREATE TABLE Cliente_Telefono(
	id_telefono INT IDENTITY(1,1) PRIMARY KEY,
	id_cliente INT NOT NULL,
	numero_telefonico VARCHAR(20) NOT NULL,
	codigo_pais VARCHAR(3) NOT NULL,
	CONSTRAINT CHK_Cliente_Telefono_numerico 
		CHECK (ISNUMERIC(numero_telefonico) = 1 ),
	CONSTRAINT CHK_codigo_pais_numerico
		CHECK (ISNUMERIC(codigo_pais) = 1)
);
GO

--Trigger para verificar que un cliente no tenga mas de 3
--numero telefonicos asociados. 
CREATE TRIGGER trg_limite_cliente_telefonos
ON Cliente_Telefono
AFTER INSERT, UPDATE
AS BEGIN
	IF EXISTS(
		SELECT id_cliente
		FROM Cliente_Telefono
		GROUP BY id_cliente
		HAVING COUNT(*) > 3
	)
	BEGIN
		RAISERROR('El Cliente no puede tener mas de tres numeros de telefono.',16,1);
		ROLLBACK TRANSACTION;
		RETURN;
	END
END;
GO

CREATE TABLE Reserva(
	id_reserva INT IDENTITY(1,1) PRIMARY KEY,
	id_cliente INT NOT NULL,
	id_habitacion INT NOT NULL,
	fecha_hora_ingreso DATETIME2 NOT NULL,
	cantidad_personas TINYINT NOT NULL,
	posee_vehiculo BIT NOT NULL,
	fecha_salida DATE NOT NULL,
	hora_salida TIME NOT NULL DEFAULT '12:00:00',
	CONSTRAINT FK_Reserva_Habitacion FOREIGN KEY (id_habitacion)
		REFERENCES Habitacion(id_habitacion),
	CONSTRAINT FK_Reserva_Cliente FOREIGN KEY (id_cliente)
		REFERENCES Cliente(id_cliente)
);
Go

CREATE TABLE Facturacion (
	id_facturacion INT IDENTITY(1,1) PRIMARY KEY,
	id_reserva INT NOT NULL,
	numero_noches TINYINT NOT NULL,
	importe_total DECIMAL(10,2) NOT NULL,
	tipo_pago VARCHAR(20) NOT NULL,
	fecha_factura DATE NOT NULL,
	CONSTRAINT FK_Facturacion_Reserva FOREIGN KEY (id_reserva)
		REFERENCES Reserva(id_reserva)
);
GO


CREATE TABLE Recreacion (
	id_recreacion INT IDENTITY(1,1) PRIMARY KEY,
	id_empresa INT NOT NULL,
	precio DECIMAL(10,2) NOT NULL,
	telefono VARCHAR(8) NOT NULL,
	nombre_contacto VARCHAR(100) NOT NULL,
	descripcion_actividad VARCHAR(255) NOT NULL,
	CONSTRAINT FK_Recreacion_Empresa FOREIGN KEY (id_empresa)
		REFERENCES Empresa (id_empresa),
	CONSTRAINT CHK_recreacion_telefono_valor_numerico 
		CHECK (ISNUMERIC(telefono) = 1) 

);
GO

CREATE TABLE Recreacion_Tipo_Actividad(
	id_tipo_actividad INT IDENTITY(1,1) PRIMARY KEY,
	id_recreacion INT NOT NULL,
	tipo_actividad VARCHAR(100) NOT NUll,
	CONSTRAINT FK_Actividad_Recreacion FOREIGN KEY (id_recreacion)
		REFERENCES Recreacion(id_recreacion)
);
GO

CREATE TABLE Recreacion_Tipo_Servicio(
	id_tipo_servicio INT IDENTITY(1,1) PRIMARY KEY,
	id_recreacion INT NOT NULL,
	tipo_servicio VARCHAR(100) NOT NUll,
	CONSTRAINT FK_Servicio_Recreacion FOREIGN KEY (id_recreacion)
		REFERENCES Recreacion(id_recreacion)
);
GO

--Creacion de vistas
CREATE VIEW Resumen_Hospedaje AS
SELECT
    E.nombre_empresa AS [nombre_hospedaje],
    E.correo_electronico,
    E.provincia,
    E.canton,
    E.distrito,
    E.barrio,
    E.senias_exactas,
    H.id_hospedaje,
    H.tipo_hospedaje,
    H.referencia_gps,
    H.enlace
FROM Empresa E
INNER JOIN Hospedaje H ON E.id_empresa = H.id_empresa;
GO

CREATE VIEW Resumen_Recreacion AS
SELECT
    E.id_empresa,
    E.cedula_juridica,
    E.nombre_empresa,
    E.correo_electronico,
    E.provincia,
    E.canton,
    E.distrito,
    E.barrio,
    E.senias_exactas,
    R.id_recreacion,
    R.precio,
    R.telefono,
    R.nombre_contacto,
    R.descripcion_actividad
FROM Empresa E
INNER JOIN Recreacion R
    ON E.id_empresa = R.id_empresa;
GO

CREATE VIEW Resumen_Reserva AS
SELECT
    R.id_reserva,
    R.fecha_hora_ingreso,
    R.fecha_salida,
    R.hora_salida,
    R.cantidad_personas,
    R.posee_vehiculo,
    (C.nombre + ' ' + C.primer_apellido + ' ' + C.segundo_apellido) AS Cliente,
    E.nombre_empresa,
	E.provincia,
    H.tipo_hospedaje,
    TH.nombre AS TipoHabitacion,
    TH.precio
FROM Reserva R
INNER JOIN Cliente C
    ON R.id_cliente = C.id_cliente
INNER JOIN Habitacion HB
    ON R.id_habitacion = HB.id_habitacion
INNER JOIN Tipo_Habitacion TH
    ON HB.id_tipo_habitacion = TH.id_tipo_habitacion
INNER JOIN Hospedaje H
    ON TH.id_hospedaje = H.id_hospedaje
INNER JOIN Empresa E
    ON H.id_empresa = E.id_empresa;
GO

CREATE VIEW Resumen_Facturacion AS
SELECT
    F.id_facturacion,
    F.numero_noches,
    F.importe_total,
    F.tipo_pago,
    F.fecha_factura,
    R.id_reserva,
    R.fecha_hora_ingreso,
    E.nombre_empresa,
    H.tipo_hospedaje,
	R.id_habitacion,
    TH.nombre AS TipoHabitacion,
    TH.precio
FROM Facturacion F
INNER JOIN Reserva R
    ON F.id_reserva = R.id_reserva
INNER JOIN Habitacion HB
    ON R.id_habitacion = HB.id_habitacion
INNER JOIN Tipo_Habitacion TH
    ON HB.id_tipo_habitacion = TH.id_tipo_habitacion
INNER JOIN Hospedaje H
    ON TH.id_hospedaje = H.id_hospedaje
INNER JOIN Empresa E
    ON H.id_empresa = E.id_empresa;
GO

CREATE VIEW Resumen_Tipo_Habitacion AS
SELECT
    TH.id_tipo_habitacion,
    TH.id_hospedaje,
    TH.nombre,
    TH.descripcion,
    TH.tipo_cama,
    TH.precio,
    COUNT(DISTINCT THC.id_comodidad) AS total_comodidades,
    COUNT(DISTINCT THF.id_foto) AS total_fotos
FROM Tipo_Habitacion TH
LEFT JOIN Tipo_Habitacion_Comodidad THC
    ON TH.id_tipo_habitacion = THC.id_tipo_habitacion
LEFT JOIN Tipo_Habitacion_Foto THF
    ON TH.id_tipo_habitacion = THF.id_tipo_habitacion
GROUP BY
    TH.id_tipo_habitacion,
    TH.id_hospedaje,
    TH.nombre,
    TH.descripcion,
    TH.tipo_cama,
    TH.precio;
GO

CREATE VIEW Resumen_Habitacion AS
SELECT
    H.id_habitacion,
    H.id_tipo_habitacion,
    H.numero,
    TH.nombre AS TipoHabitacion,
    TH.descripcion,
    TH.tipo_cama,
    TH.precio
FROM Habitacion H
INNER JOIN Tipo_Habitacion TH
    ON H.id_tipo_habitacion = TH.id_tipo_habitacion;
GO

--Creacion de PRODEDURES
CREATE PROCEDURE sp_Insertar_Hospedaje
   
    @cedula_juridica     VARCHAR(12),
    @nombre_empresa      VARCHAR(100),
    @correo_electronico  VARCHAR(100),
    @provincia           VARCHAR(10),
    @canton              VARCHAR(25),
    @distrito            VARCHAR(30),
    @barrio              VARCHAR(50),
    @senias_exactas      VARCHAR(255),
    
   
    @tipo_hospedaje      VARCHAR(50),
    @referencia_gps      VARCHAR(100) = NULL,
    @enlace              VARCHAR(255) = NULL,
    
    
    @numero_telefonico   VARCHAR(8) = NULL,
    @servicio            VARCHAR(100) = NULL,
    @plataforma          VARCHAR(20) = NULL,
    @red_enlace          VARCHAR(100) = NULL
AS
BEGIN
    SET NOCOUNT ON;

    BEGIN TRY
        BEGIN TRANSACTION;
        
            INSERT INTO Empresa 
                (cedula_juridica, nombre_empresa, correo_electronico,
				provincia, canton, distrito, barrio, senias_exactas)
            VALUES 
                (@cedula_juridica, @nombre_empresa, @correo_electronico,
				@provincia, @canton, @distrito, @barrio, @senias_exactas);
            
            DECLARE @id_nueva_empresa INT = SCOPE_IDENTITY();
            
       
            INSERT INTO Hospedaje
                (id_empresa, tipo_hospedaje, referencia_gps, enlace)
            VALUES
                (@id_nueva_empresa, @tipo_hospedaje, @referencia_gps, @enlace);
            
            DECLARE @id_nuevo_hospedaje INT = SCOPE_IDENTITY();
            
          
            INSERT INTO Hospedaje_Telefono (id_hospedaje, numero_telefonico)
            VALUES (@id_nuevo_hospedaje, @numero_telefonico);
            
          
            INSERT INTO Hospedaje_Servicio (id_hospedaje, servicio)
            VALUES (@id_nuevo_hospedaje, @servicio);
            
            
            INSERT INTO Hospedaje_Red_Social (id_hospedaje, plataforma, enlace)
            VALUES (@id_nuevo_hospedaje, @plataforma, @red_enlace);
            
        COMMIT TRANSACTION;
    
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;
        
        DECLARE @ErrorMessage NVARCHAR(4000) = ERROR_MESSAGE(),
                @ErrorSeverity INT = ERROR_SEVERITY(),
                @ErrorState INT = ERROR_STATE();
        RAISERROR(@ErrorMessage, @ErrorSeverity, @ErrorState);
    END CATCH
END;
GO

CREATE PROCEDURE sp_Actualizar_Hospedaje

    @id_empresa         INT,
    @id_hospedaje       INT,
    
    @cedula_juridica     VARCHAR(12)  = NULL,
    @nombre_empresa      VARCHAR(100) = NULL,
    @correo_electronico  VARCHAR(100) = NULL,
    @provincia           VARCHAR(10)  = NULL,
    @canton              VARCHAR(25)  = NULL,
    @distrito            VARCHAR(30)  = NULL,
    @barrio              VARCHAR(50)  = NULL,
    @senias_exactas      VARCHAR(255) = NULL,
    
    @tipo_hospedaje      VARCHAR(50)  = NULL,
    @referencia_gps      VARCHAR(100) = NULL,
    @enlace              VARCHAR(255) = NULL
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        BEGIN TRANSACTION;
        
            UPDATE Empresa
            SET 
				cedula_juridica    = COALESCE(@cedula_juridica, cedula_juridica),
                nombre_empresa     = COALESCE(@nombre_empresa, nombre_empresa),
                correo_electronico = COALESCE(@correo_electronico, correo_electronico),
                provincia          = COALESCE(@provincia, provincia),
                canton             = COALESCE(@canton, canton),
                distrito           = COALESCE(@distrito, distrito),
                barrio             = COALESCE(@barrio, barrio),
                senias_exactas     = COALESCE(@senias_exactas, senias_exactas)
            WHERE id_empresa = @id_empresa;
            
            UPDATE Hospedaje
            SET 
				tipo_hospedaje = COALESCE(@tipo_hospedaje, tipo_hospedaje),
                referencia_gps = COALESCE(@referencia_gps, referencia_gps),
                enlace         = COALESCE(@enlace, enlace)
            WHERE id_hospedaje = @id_hospedaje;
        
        COMMIT TRANSACTION;
    
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;
        DECLARE @ErrorMessage NVARCHAR(4000) = ERROR_MESSAGE(),
                @ErrorSeverity INT = ERROR_SEVERITY(),
                @ErrorState INT = ERROR_STATE();
        RAISERROR(@ErrorMessage, @ErrorSeverity, @ErrorState);
    END CATCH
END;
GO

CREATE PROCEDURE sp_Eliminar_Hospedaje
    @id_hospedaje INT
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        BEGIN TRANSACTION;
            
            DECLARE @id_empresa INT;
            SELECT @id_empresa = id_empresa FROM Hospedaje WHERE id_hospedaje = @id_hospedaje;
            
            DELETE FROM Hospedaje_Telefono  WHERE id_hospedaje = @id_hospedaje;
            DELETE FROM Hospedaje_Servicio   WHERE id_hospedaje = @id_hospedaje;
            DELETE FROM Hospedaje_Red_Social WHERE id_hospedaje = @id_hospedaje;
            
            DELETE FROM Hospedaje WHERE id_hospedaje = @id_hospedaje;
            DELETE FROM Empresa    WHERE id_empresa = @id_empresa;
            
        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;
        DECLARE @ErrorMessage NVARCHAR(4000)= ERROR_MESSAGE(),
                @ErrorSeverity INT = ERROR_SEVERITY(),
                @ErrorState INT = ERROR_STATE();
        RAISERROR(@ErrorMessage, @ErrorSeverity, @ErrorState);
    END CATCH
END;
GO

CREATE PROCEDURE sp_Buscar_Hospedaje
    @provincia      VARCHAR(10) = NULL,
    @tipo_hospedaje VARCHAR(50) = NULL
AS
BEGIN
    SET NOCOUNT ON;
    
    SELECT *
    FROM Resumen_Hospedaje
    WHERE (@provincia IS NULL OR provincia = @provincia)
      AND (@tipo_hospedaje IS NULL OR tipo_hospedaje = @tipo_hospedaje);
END;
GO


CREATE PROCEDURE sp_Insertar_Hospedaje_Telefono
    @id_hospedaje      INT,
    @numero_telefonico VARCHAR(8)
AS
BEGIN
    SET NOCOUNT ON;
    INSERT INTO Hospedaje_Telefono (id_hospedaje, numero_telefonico)
    VALUES (@id_hospedaje, @numero_telefonico);
END;
GO

CREATE PROCEDURE sp_Actualizar_Hospedaje_Telefono
    @id_telefono       INT,
    @id_hospedaje      INT    = NULL,
    @numero_telefonico VARCHAR(8)= NULL
AS
BEGIN
    SET NOCOUNT ON;
    UPDATE Hospedaje_Telefono
    SET 
		id_hospedaje = COALESCE(@id_hospedaje, id_hospedaje),
        numero_telefonico = COALESCE(@numero_telefonico, numero_telefonico)
    WHERE id_telefono = @id_telefono;
END;
GO

CREATE PROCEDURE sp_Eliminar_Hospedaje_Telefono
    @id_telefono INT
AS
BEGIN
    SET NOCOUNT ON;
    DELETE FROM Hospedaje_Telefono WHERE id_telefono = @id_telefono;
END;
GO

CREATE PROCEDURE sp_Insertar_Hospedaje_Servicio
    @id_hospedaje INT,
    @servicio    VARCHAR(100)
AS
BEGIN
    SET NOCOUNT ON;
    INSERT INTO Hospedaje_Servicio (id_hospedaje, servicio)
    VALUES (@id_hospedaje, @servicio);
END;
GO

CREATE PROCEDURE sp_Actualizar_Hospedaje_Servicio
    @id_servicio INT,
    @id_hospedaje INT    = NULL,
    @servicio    VARCHAR(100)= NULL
AS
BEGIN
    SET NOCOUNT ON;
    UPDATE Hospedaje_Servicio
    SET 
		id_hospedaje = COALESCE(@id_hospedaje, id_hospedaje),
        servicio = COALESCE(@servicio, servicio)
    WHERE id_servicio = @id_servicio;
END;
GO

CREATE PROCEDURE sp_Eliminar_Hospedaje_Servicio
    @id_servicio INT
AS
BEGIN
    SET NOCOUNT ON;
    DELETE FROM Hospedaje_Servicio WHERE id_servicio = @id_servicio;
END;
GO

CREATE PROCEDURE sp_Insertar_Hospedaje_Red_Social
    @id_hospedaje INT,
    @plataforma  VARCHAR(20),
    @enlace      VARCHAR(100)
AS
BEGIN
    SET NOCOUNT ON;
    INSERT INTO Hospedaje_Red_Social (id_hospedaje, plataforma, enlace)
    VALUES (@id_hospedaje, @plataforma, @enlace);
END;
GO

CREATE PROCEDURE sp_Actualizar_Hospedaje_Red_Social
    @id_red_social INT,
    @id_hospedaje  INT    = NULL,
    @plataforma    VARCHAR(20)= NULL,
    @enlace        VARCHAR(100)= NULL
AS
BEGIN
    SET NOCOUNT ON;
    UPDATE Hospedaje_Red_Social
    SET 
		id_hospedaje = COALESCE(@id_hospedaje, id_hospedaje),
        plataforma  = COALESCE(@plataforma, plataforma),
        enlace      = COALESCE(@enlace, enlace)
    WHERE id_red_social = @id_red_social;
END;
GO

CREATE PROCEDURE sp_Eliminar_Hospedaje_Red_Social
    @id_red_social INT
AS
BEGIN
    SET NOCOUNT ON;
    DELETE FROM Hospedaje_Red_Social WHERE id_red_social = @id_red_social;
END;
GO

CREATE PROCEDURE sp_Insertar_Tipo_Habitacion
    @id_hospedaje INT,
    @nombre       VARCHAR(30),
    @descripcion  VARCHAR(255),
    @tipo_cama    VARCHAR(20),
    @precio       DECIMAL(10,2)
AS
BEGIN
    SET NOCOUNT ON;
    INSERT INTO Tipo_Habitacion
        (id_hospedaje, nombre, descripcion, tipo_cama, precio)
    VALUES
        (@id_hospedaje, @nombre, @descripcion, @tipo_cama, @precio);
END;
GO

CREATE PROCEDURE sp_Actualizar_Tipo_Habitacion
    @id_tipo_habitacion INT,
    @id_hospedaje       INT        = NULL,
    @nombre             VARCHAR(30)= NULL,
    @descripcion        VARCHAR(255)= NULL,
    @tipo_cama          VARCHAR(20)= NULL,
    @precio             DECIMAL(10,2)= NULL
AS
BEGIN
    SET NOCOUNT ON;
    UPDATE Tipo_Habitacion
    SET 
		id_hospedaje = COALESCE(@id_hospedaje, id_hospedaje),
        nombre       = COALESCE(@nombre, nombre),
        descripcion  = COALESCE(@descripcion, descripcion),
        tipo_cama    = COALESCE(@tipo_cama, tipo_cama),
        precio       = COALESCE(@precio, precio)
    WHERE id_tipo_habitacion = @id_tipo_habitacion;
END;
GO

CREATE PROCEDURE sp_Eliminar_Tipo_Habitacion
    @id_tipo_habitacion INT
AS
BEGIN
    SET NOCOUNT ON;
    DELETE FROM Tipo_Habitacion WHERE id_tipo_habitacion = @id_tipo_habitacion;
END;
GO

CREATE PROCEDURE sp_Buscar_Tipo_Habitacion
    @nombre      VARCHAR(30) = NULL,
    @precio_min  DECIMAL(10,2) = NULL,
    @precio_max  DECIMAL(10,2) = NULL
AS
BEGIN
    SET NOCOUNT ON;
    
    SELECT *
    FROM Resumen_Tipo_Habitacion
    WHERE (@nombre IS NULL OR nombre LIKE '%' + @nombre + '%')
      AND (@precio_min IS NULL OR precio >= @precio_min)
      AND (@precio_max IS NULL OR precio <= @precio_max);
END;
GO


CREATE PROCEDURE sp_Insertar_Tipo_Habitacion_Comodidad
    @id_tipo_habitacion INT,
    @comodidad          VARCHAR(50)
AS
BEGIN
    SET NOCOUNT ON;
    INSERT INTO Tipo_Habitacion_Comodidad (id_tipo_habitacion, comodidad)
    VALUES (@id_tipo_habitacion, @comodidad);
END;
GO

CREATE PROCEDURE sp_Actualizar_Tipo_Habitacion_Comodidad
    @id_comodidad       INT,
    @id_tipo_habitacion INT       = NULL,
    @comodidad          VARCHAR(50) = NULL
AS
BEGIN
    SET NOCOUNT ON;
    UPDATE Tipo_Habitacion_Comodidad
    SET 
		id_tipo_habitacion = COALESCE(@id_tipo_habitacion, id_tipo_habitacion),
        comodidad          = COALESCE(@comodidad, comodidad)
    WHERE id_comodidad = @id_comodidad;
END;
GO

CREATE PROCEDURE sp_Eliminar_Tipo_Habitacion_Comodidad
    @id_comodidad INT
AS
BEGIN
    SET NOCOUNT ON;
    DELETE FROM Tipo_Habitacion_Comodidad WHERE id_comodidad = @id_comodidad;
END;
GO

CREATE PROCEDURE sp_Insertar_Tipo_Habitacion_Foto
    @id_tipo_habitacion INT,
    @foto               VARBINARY(MAX)
AS
BEGIN
    SET NOCOUNT ON;
    INSERT INTO Tipo_Habitacion_Foto (id_tipo_habitacion, foto)
    VALUES (@id_tipo_habitacion, @foto);
END;
GO

CREATE PROCEDURE sp_Actualizar_Tipo_Habitacion_Foto
    @id_foto            INT,
    @id_tipo_habitacion INT         = NULL,
    @foto               VARBINARY(MAX)= NULL
AS
BEGIN
    SET NOCOUNT ON;
    UPDATE Tipo_Habitacion_Foto
    SET 
		id_tipo_habitacion = COALESCE(@id_tipo_habitacion, id_tipo_habitacion),
        foto               = COALESCE(@foto, foto)
    WHERE id_foto = @id_foto;
END;
GO

CREATE PROCEDURE sp_Eliminar_Tipo_Habitacion_Foto
    @id_foto INT
AS
BEGIN
    SET NOCOUNT ON;
    DELETE FROM Tipo_Habitacion_Foto WHERE id_foto = @id_foto;
END;
GO

CREATE PROCEDURE sp_Insertar_Habitacion
    @id_tipo_habitacion INT,
    @numero             VARCHAR(10)
AS
BEGIN
    SET NOCOUNT ON;
    INSERT INTO Habitacion (id_tipo_habitacion, numero)
    VALUES (@id_tipo_habitacion, @numero);
END;
GO

CREATE PROCEDURE sp_Actualizar_Habitacion
    @id_habitacion      INT,
    @id_tipo_habitacion INT        = NULL,
    @numero             VARCHAR(10)= NULL
AS
BEGIN
    SET NOCOUNT ON;
    UPDATE Habitacion
    SET 
		id_tipo_habitacion = COALESCE(@id_tipo_habitacion, id_tipo_habitacion),
        numero = COALESCE(@numero, numero)
    WHERE id_habitacion = @id_habitacion;
END;
GO

CREATE PROCEDURE sp_Eliminar_Habitacion
    @id_habitacion INT
AS
BEGIN
    SET NOCOUNT ON;
    DELETE FROM Habitacion WHERE id_habitacion = @id_habitacion;
END;
GO

CREATE PROCEDURE sp_Buscar_Habitacion
    @numero             VARCHAR(10) = NULL,
    @id_tipo_habitacion INT         = NULL
AS
BEGIN
    SET NOCOUNT ON;
    
    SELECT *
    FROM Resumen_Habitacion
    WHERE (@numero IS NULL OR numero LIKE '%' + @numero + '%')
      AND (@id_tipo_habitacion IS NULL OR id_tipo_habitacion = @id_tipo_habitacion);
END;
GO


CREATE PROCEDURE sp_Insertar_Recreacion
   
    @cedula_juridica      VARCHAR(12),
    @nombre_empresa       VARCHAR(100),
    @correo_electronico   VARCHAR(100),
    @provincia            VARCHAR(10),
    @canton               VARCHAR(25),
    @distrito             VARCHAR(30),
    @barrio               VARCHAR(50),
    @senias_exactas       VARCHAR(255),

    
    @precio               DECIMAL(10,2),
    @telefono             VARCHAR(8),
    @nombre_contacto      VARCHAR(100),
    @descripcion_actividad VARCHAR(255)
AS
BEGIN
    SET NOCOUNT ON;

    BEGIN TRY
        BEGIN TRANSACTION;
        
            
            INSERT INTO Empresa 
                (cedula_juridica, nombre_empresa, correo_electronico,
				provincia, canton, distrito, barrio, senias_exactas)
            VALUES 
                (@cedula_juridica, @nombre_empresa, @correo_electronico,
				@provincia, @canton, @distrito, @barrio, @senias_exactas);
            
            DECLARE @id_nueva_empresa INT = SCOPE_IDENTITY();
            

            INSERT INTO Recreacion
                (id_empresa, precio, telefono, nombre_contacto, descripcion_actividad)
            VALUES
                (@id_nueva_empresa, @precio, @telefono, @nombre_contacto, @descripcion_actividad);
            
            DECLARE @id_nueva_recreacion INT = SCOPE_IDENTITY();
            
        COMMIT TRANSACTION;
        
  
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;
        
        DECLARE @ErrorMessage NVARCHAR(4000) = ERROR_MESSAGE(),
                @ErrorSeverity INT = ERROR_SEVERITY(),
                @ErrorState INT = ERROR_STATE();
        RAISERROR(@ErrorMessage, @ErrorSeverity, @ErrorState);
    END CATCH
END;
GO

CREATE PROCEDURE sp_Actualizar_Recreacion
    @id_empresa          INT,
    @id_recreacion       INT,
    
    @cedula_juridica     VARCHAR(12)  = NULL,
    @nombre_empresa      VARCHAR(100) = NULL,
    @correo_electronico  VARCHAR(100) = NULL,
    @provincia           VARCHAR(10)  = NULL,
    @canton              VARCHAR(25)  = NULL,
    @distrito            VARCHAR(30)  = NULL,
    @barrio              VARCHAR(50)  = NULL,
    @senias_exactas      VARCHAR(255) = NULL,
    
    @precio              DECIMAL(10,2) = NULL,
    @telefono            VARCHAR(8)    = NULL,
    @nombre_contacto     VARCHAR(100)  = NULL,
    @descripcion_actividad VARCHAR(255)= NULL
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        BEGIN TRANSACTION;
        
            UPDATE Empresa
            SET 
				cedula_juridica    = COALESCE(@cedula_juridica, cedula_juridica),
                nombre_empresa     = COALESCE(@nombre_empresa, nombre_empresa),
                correo_electronico = COALESCE(@correo_electronico, correo_electronico),
                provincia          = COALESCE(@provincia, provincia),
                canton             = COALESCE(@canton, canton),
                distrito           = COALESCE(@distrito, distrito),
                barrio             = COALESCE(@barrio, barrio),
                senias_exactas     = COALESCE(@senias_exactas, senias_exactas)
            WHERE id_empresa = @id_empresa;
            
            UPDATE Recreacion
            SET 
				precio              = COALESCE(@precio, precio),
                telefono            = COALESCE(@telefono, telefono),
                nombre_contacto     = COALESCE(@nombre_contacto, nombre_contacto),
                descripcion_actividad = COALESCE(@descripcion_actividad, descripcion_actividad)
            WHERE id_recreacion = @id_recreacion;
        
        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;
        DECLARE @ErrorMessage NVARCHAR(4000)= ERROR_MESSAGE(),
                @ErrorSeverity INT= ERROR_SEVERITY(),
                @ErrorState INT= ERROR_STATE();
        RAISERROR(@ErrorMessage, @ErrorSeverity, @ErrorState);
    END CATCH
END;
GO

CREATE PROCEDURE sp_Eliminar_Recreacion
    @id_recreacion INT
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        BEGIN TRANSACTION;
        
            DECLARE @id_empresa INT;
            SELECT @id_empresa = id_empresa FROM Recreacion WHERE id_recreacion = @id_recreacion;
            
            DELETE FROM Recreacion WHERE id_recreacion = @id_recreacion;
            DELETE FROM Empresa    WHERE id_empresa = @id_empresa;
        
        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;
        DECLARE @ErrorMessage NVARCHAR(4000)= ERROR_MESSAGE(),
                @ErrorSeverity INT= ERROR_SEVERITY(),
                @ErrorState INT= ERROR_STATE();
        RAISERROR(@ErrorMessage, @ErrorSeverity, @ErrorState);
    END CATCH
END;
GO

CREATE PROCEDURE sp_Buscar_Recreacion
    @provincia  VARCHAR(10) = NULL,
    @precio_min DECIMAL(10,2) = NULL,
    @precio_max DECIMAL(10,2) = NULL
AS
BEGIN
    SET NOCOUNT ON;
    
    SELECT *
    FROM Resumen_Recreacion
    WHERE (@provincia IS NULL OR provincia = @provincia)
      AND (@precio_min IS NULL OR precio >= @precio_min)
      AND (@precio_max IS NULL OR precio <= @precio_max);
END;
GO


CREATE PROCEDURE sp_Insertar_Recreacion_Tipo_Actividad
    @id_recreacion  INT,
    @tipo_actividad VARCHAR(50)
AS
BEGIN
    SET NOCOUNT ON;
    INSERT INTO Recreacion_Tipo_Actividad (id_recreacion, tipo_actividad)
    VALUES (@id_recreacion, @tipo_actividad);
END;
GO

CREATE PROCEDURE sp_Actualizar_Recreacion_Tipo_Actividad
    @id_tipo_actividad INT,
    @id_recreacion     INT    = NULL,
    @tipo_actividad    VARCHAR(50)= NULL
AS
BEGIN
    SET NOCOUNT ON;
    UPDATE Recreacion_Tipo_Actividad
    SET 
		id_recreacion = COALESCE(@id_recreacion, id_recreacion),
        tipo_actividad = COALESCE(@tipo_actividad, tipo_actividad)
    WHERE id_tipo_actividad = @id_tipo_actividad;
END;
GO

CREATE PROCEDURE sp_Eliminar_Recreacion_Tipo_Actividad
    @id_tipo_actividad INT
AS
BEGIN
    SET NOCOUNT ON;
    DELETE FROM Recreacion_Tipo_Actividad WHERE id_tipo_actividad = @id_tipo_actividad;
END;
GO

CREATE PROCEDURE sp_Insertar_Recreacion_Tipo_Servicio
    @id_recreacion INT,
    @tipo_servicio     VARCHAR(100)
AS
BEGIN
    SET NOCOUNT ON;
    INSERT INTO Recreacion_Tipo_Servicio (id_recreacion, tipo_servicio)
    VALUES (@id_recreacion, @tipo_servicio);
END;
GO

CREATE PROCEDURE sp_Actualizar_Recreacion_Tipo_Servicio
    @id_tipo_servicio INT,
    @id_recreacion    INT    = NULL,
    @tipo_servicio         VARCHAR(100)= NULL
AS
BEGIN
    SET NOCOUNT ON;
    UPDATE Recreacion_Tipo_Servicio
    SET 
		id_recreacion = COALESCE(@id_recreacion, id_recreacion),
        tipo_servicio      = COALESCE(@tipo_servicio, tipo_servicio)
    WHERE id_tipo_servicio = @id_tipo_servicio;
END;
GO

CREATE PROCEDURE sp_Eliminar_Recreacion_Tipo_Servicio
    @id_tipo_servicio INT
AS
BEGIN
    SET NOCOUNT ON;
    DELETE FROM Recreacion_Tipo_Servicio WHERE id_tipo_servicio = @id_tipo_servicio;
END;
GO


CREATE PROCEDURE sp_Insertar_Cliente
    @nombre                VARCHAR(40),
    @primer_apellido       VARCHAR(40),
    @segundo_apellido      VARCHAR(40),
    @fecha_nacimiento      DATE,
    @tipo_identificacion   VARCHAR(20),
    @numero_identificacion VARCHAR(50),
    @pais_residencia       VARCHAR(50),
    @correo_electronico    VARCHAR(100),
    @provincia             VARCHAR(10) = NULL,
    @canton                VARCHAR(25) = NULL,
    @distrito              VARCHAR(30) = NULL
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        BEGIN TRANSACTION;
        
            INSERT INTO Cliente
              (nombre, primer_apellido, segundo_apellido, fecha_nacimiento,
               tipo_identificacion, numero_identificacion, pais_residencia, correo_electronico,
               provincia, canton, distrito)
            VALUES
              (@nombre, @primer_apellido, @segundo_apellido, @fecha_nacimiento,
               @tipo_identificacion, @numero_identificacion, @pais_residencia, @correo_electronico,
               @provincia, @canton, @distrito);
        
        COMMIT TRANSACTION;

    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;
        DECLARE @ErrorMessage NVARCHAR(4000)= ERROR_MESSAGE(),
                @ErrorSeverity INT= ERROR_SEVERITY(),
                @ErrorState INT= ERROR_STATE();
        RAISERROR(@ErrorMessage, @ErrorSeverity, @ErrorState);
    END CATCH
END;
GO

CREATE PROCEDURE sp_Actualizar_Cliente
    @id_cliente            INT,
    @nombre                VARCHAR(40)  = NULL,
    @primer_apellido       VARCHAR(40)  = NULL,
    @segundo_apellido      VARCHAR(40)  = NULL,
    @fecha_nacimiento      DATE         = NULL,
    @tipo_identificacion   VARCHAR(20)  = NULL,
    @numero_identificacion VARCHAR(50)  = NULL,
    @pais_residencia       VARCHAR(50)  = NULL,
    @correo_electronico    VARCHAR(100) = NULL,
    @provincia             VARCHAR(10)  = NULL,
    @canton                VARCHAR(25)  = NULL,
    @distrito              VARCHAR(30)  = NULL
AS
BEGIN
    SET NOCOUNT ON;
    UPDATE Cliente
    SET
      nombre                = COALESCE(@nombre, nombre),
      primer_apellido       = COALESCE(@primer_apellido, primer_apellido),
      segundo_apellido      = COALESCE(@segundo_apellido, segundo_apellido),
      fecha_nacimiento      = COALESCE(@fecha_nacimiento, fecha_nacimiento),
      tipo_identificacion   = COALESCE(@tipo_identificacion, tipo_identificacion),
      numero_identificacion = COALESCE(@numero_identificacion, numero_identificacion),
      pais_residencia       = COALESCE(@pais_residencia, pais_residencia),
      correo_electronico    = COALESCE(@correo_electronico, correo_electronico),
      provincia             = COALESCE(@provincia, provincia),
      canton                = COALESCE(@canton, canton),
      distrito              = COALESCE(@distrito, distrito)
    WHERE id_cliente = @id_cliente;
END;
GO


CREATE PROCEDURE sp_Eliminar_Cliente
    @id_cliente INT
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        BEGIN TRANSACTION;
        
            DELETE FROM Cliente_Telefono WHERE id_cliente = @id_cliente;
            DELETE FROM Cliente WHERE id_cliente = @id_cliente;
        
        COMMIT TRANSACTION;
     
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;
        DECLARE @ErrorMessage NVARCHAR(4000)= ERROR_MESSAGE(),
                @ErrorSeverity INT= ERROR_SEVERITY(),
                @ErrorState INT= ERROR_STATE();
        RAISERROR(@ErrorMessage, @ErrorSeverity, @ErrorState);
    END CATCH
END;
GO

CREATE PROCEDURE sp_Buscar_Cliente
    @nombre                VARCHAR(40) = NULL,
    @numero_identificacion VARCHAR(50) = NULL,
    @pais_residencia       VARCHAR(50) = NULL
AS
BEGIN
    SET NOCOUNT ON;
    SELECT *
    FROM Cliente
    WHERE (@nombre IS NULL OR nombre LIKE '%' + @nombre + '%')
      AND (@numero_identificacion IS NULL OR numero_identificacion = @numero_identificacion)
      AND (@pais_residencia IS NULL OR pais_residencia = @pais_residencia);
END;
GO

CREATE PROCEDURE sp_Insertar_Cliente_Telefono
    @id_cliente        INT,
    @numero_telefonico VARCHAR(8),
    @codigo_pais       VARCHAR(4)
AS
BEGIN
    SET NOCOUNT ON;
    INSERT INTO Cliente_Telefono (id_cliente, numero_telefonico, codigo_pais)
    VALUES (@id_cliente, @numero_telefonico, @codigo_pais);
    
END;
GO

CREATE PROCEDURE sp_Actualizar_Cliente_Telefono
    @id_telefono       INT,
    @id_cliente        INT    = NULL,
    @numero_telefonico VARCHAR(20)  = NULL,
    @codigo_pais       VARCHAR(4)  = NULL
AS
BEGIN
    SET NOCOUNT ON;
    UPDATE Cliente_Telefono
    SET 
		id_cliente        = COALESCE(@id_cliente, id_cliente),
        numero_telefonico = COALESCE(@numero_telefonico, numero_telefonico),
        codigo_pais       = COALESCE(@codigo_pais, codigo_pais)
    WHERE id_telefono = @id_telefono;
END;
GO

CREATE PROCEDURE sp_Eliminar_Cliente_Telefono
    @id_telefono INT
AS
BEGIN
    SET NOCOUNT ON;
    DELETE FROM Cliente_Telefono WHERE id_telefono = @id_telefono;
END;
GO

CREATE PROCEDURE sp_Insertar_Reserva
    @id_cliente         INT,
    @id_habitacion      INT,
    @fecha_hora_ingreso DATETIME2,
    @cantidad_personas  TINYINT,
    @posee_vehiculo     BIT,
    @fecha_salida       DATE,
    @hora_salida        TIME
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        BEGIN TRANSACTION;
        
            INSERT INTO Reserva
              (id_cliente, id_habitacion, fecha_hora_ingreso, cantidad_personas, posee_vehiculo, fecha_salida, hora_salida)
            VALUES
              (@id_cliente, @id_habitacion, @fecha_hora_ingreso, @cantidad_personas, @posee_vehiculo, @fecha_salida, @hora_salida);
        
        COMMIT TRANSACTION;
        
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;
        DECLARE @ErrorMessage NVARCHAR(4000)= ERROR_MESSAGE(), 
                @ErrorSeverity INT= ERROR_SEVERITY(), 
                @ErrorState INT= ERROR_STATE();
        RAISERROR(@ErrorMessage, @ErrorSeverity, @ErrorState);
    END CATCH
END;
GO

CREATE PROCEDURE sp_Actualizar_Reserva
    @id_reserva         INT,
    @id_cliente         INT       = NULL,
    @id_habitacion      INT       = NULL,
    @fecha_hora_ingreso DATETIME2 = NULL,
    @cantidad_personas  TINYINT   = NULL,
    @posee_vehiculo     BIT       = NULL,
    @fecha_salida       DATE      = NULL,
    @hora_salida        TIME      = NULL
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        BEGIN TRANSACTION;
        
            UPDATE Reserva
            SET 
				id_cliente         = COALESCE(@id_cliente, id_cliente),
				id_habitacion      = COALESCE(@id_habitacion, id_habitacion),
				fecha_hora_ingreso = COALESCE(@fecha_hora_ingreso, fecha_hora_ingreso),
				cantidad_personas  = COALESCE(@cantidad_personas, cantidad_personas),
				posee_vehiculo     = COALESCE(@posee_vehiculo, posee_vehiculo),
				fecha_salida       = COALESCE(@fecha_salida, fecha_salida),
				hora_salida        = COALESCE(@hora_salida, hora_salida)
            WHERE id_reserva = @id_reserva;
        
        COMMIT TRANSACTION;
       
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;
        DECLARE @ErrorMessage NVARCHAR(4000)= ERROR_MESSAGE(),
                @ErrorSeverity INT= ERROR_SEVERITY(),
                @ErrorState INT= ERROR_STATE();
        RAISERROR(@ErrorMessage, @ErrorSeverity, @ErrorState);
    END CATCH
END;
GO

CREATE PROCEDURE sp_Eliminar_Reserva
    @id_reserva INT
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        BEGIN TRANSACTION;
        
            DELETE FROM Reserva WHERE id_reserva = @id_reserva;
        
        COMMIT TRANSACTION;
        
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;
        DECLARE @ErrorMessage NVARCHAR(4000)= ERROR_MESSAGE(),
                @ErrorSeverity INT= ERROR_SEVERITY(),
                @ErrorState INT= ERROR_STATE();
        RAISERROR(@ErrorMessage, @ErrorSeverity, @ErrorState);
    END CATCH
END;
GO

CREATE PROCEDURE sp_Buscar_Reserva
    @provincia          VARCHAR(10) = NULL,
    @tipo_hospedaje     VARCHAR(50) = NULL,
    @fecha_ingreso_inicio DATETIME2 = NULL,
    @fecha_ingreso_fin    DATETIME2 = NULL,
    @cantidad_personas  TINYINT = NULL,
    @posee_vehiculo     BIT = NULL
AS
BEGIN
    SET NOCOUNT ON;
    
    SELECT *
    FROM Resumen_Reserva
    WHERE (@provincia IS NULL OR provincia = @provincia)
      AND (@tipo_hospedaje IS NULL OR tipo_hospedaje = @tipo_hospedaje)
      AND ((@fecha_ingreso_inicio IS NULL AND @fecha_ingreso_fin IS NULL)
           OR (fecha_hora_ingreso BETWEEN @fecha_ingreso_inicio AND @fecha_ingreso_fin))
      AND (@cantidad_personas IS NULL OR cantidad_personas = @cantidad_personas)
      AND (@posee_vehiculo IS NULL OR posee_vehiculo = @posee_vehiculo);
END;
GO


CREATE PROCEDURE sp_Insertar_Facturacion
    @id_reserva    INT,
    @numero_noches TINYINT,
    @importe_total DECIMAL(10,2) = NULL, 
    @tipo_pago     VARCHAR(20),
    @fecha_factura DATE
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        BEGIN TRANSACTION;
        
            
            IF @importe_total IS NULL
            BEGIN
                DECLARE @precio DECIMAL(10,2);
                
                SELECT TOP 1 @precio = TH.precio
                FROM Reserva R
                INNER JOIN Habitacion H ON R.id_habitacion = H.id_habitacion
                INNER JOIN Tipo_Habitacion TH ON H.id_tipo_habitacion = TH.id_tipo_habitacion
                WHERE R.id_reserva = @id_reserva;
                
                SET @importe_total = @precio * @numero_noches;
            END
            
            INSERT INTO Facturacion
              (id_reserva, numero_noches, importe_total, tipo_pago, fecha_factura)
            VALUES
              (@id_reserva, @numero_noches, @importe_total, @tipo_pago, @fecha_factura);
        
        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;
        DECLARE @ErrorMessage NVARCHAR(4000)= ERROR_MESSAGE(),
                @ErrorSeverity INT= ERROR_SEVERITY(),
                @ErrorState INT= ERROR_STATE();
        RAISERROR(@ErrorMessage, @ErrorSeverity, @ErrorState);
    END CATCH
END;
GO


CREATE PROCEDURE sp_Actualizar_Facturacion
    @id_facturacion INT,
    @id_reserva     INT        = NULL,
    @numero_noches  TINYINT    = NULL,
    @importe_total  DECIMAL(10,2) = NULL,
    @tipo_pago      VARCHAR(20)= NULL,
    @fecha_factura  DATE       = NULL
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        BEGIN TRANSACTION;
        
            UPDATE Facturacion
            SET 
				id_reserva    = COALESCE(@id_reserva, id_reserva),
				numero_noches = COALESCE(@numero_noches, numero_noches),
				importe_total = COALESCE(@importe_total, importe_total),
				tipo_pago     = COALESCE(@tipo_pago, tipo_pago),
				fecha_factura = COALESCE(@fecha_factura, fecha_factura)
            WHERE id_facturacion = @id_facturacion;
        
        COMMIT TRANSACTION;
    
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;
        DECLARE @ErrorMessage NVARCHAR(4000)= ERROR_MESSAGE(),
                @ErrorSeverity INT= ERROR_SEVERITY(),
                @ErrorState INT= ERROR_STATE();
        RAISERROR(@ErrorMessage, @ErrorSeverity, @ErrorState);
    END CATCH
END;
GO

CREATE PROCEDURE sp_Eliminar_Facturacion
    @id_facturacion INT
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        BEGIN TRANSACTION;
        
            DELETE FROM Facturacion WHERE id_facturacion = @id_facturacion;
        
        COMMIT TRANSACTION;
        
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;
        DECLARE @ErrorMessage NVARCHAR(4000)= ERROR_MESSAGE(),
                @ErrorSeverity INT = ERROR_SEVERITY(),
                @ErrorState INT= ERROR_STATE();
        RAISERROR(@ErrorMessage, @ErrorSeverity, @ErrorState);
    END CATCH
END;
GO

CREATE PROCEDURE sp_Buscar_Facturacion
    @fecha_inicio DATE = NULL,
    @fecha_fin    DATE = NULL,
    @tipo_pago    VARCHAR(20) = NULL,
    @id_habitacion INT = NULL
AS
BEGIN
    SET NOCOUNT ON;
    
    SELECT *
    FROM Resumen_Facturacion
    WHERE (@fecha_inicio IS NULL OR fecha_factura >= @fecha_inicio)
      AND (@fecha_fin IS NULL OR fecha_factura <= @fecha_fin)
      AND (@tipo_pago IS NULL OR tipo_pago = @tipo_pago)
      AND (@id_habitacion IS NULL OR id_habitacion = @id_habitacion);
END;
GO

-- ================================================
-- 1. Tabla Empresa 
-- ================================================
INSERT INTO Empresa (cedula_juridica, nombre_empresa, correo_electronico, provincia, canton, distrito, barrio, senias_exactas)
VALUES ('3-101-100001', 'Empresa 1', 'empresa1@example.com', 'San José', 'Canton1', 'Distrito1', 'Barrio1', 'Señas 1'),
	   ('3-102-100002', 'Empresa 2', 'empresa2@example.com', 'Alajuela', 'Canton2', 'Distrito2', 'Barrio2', 'Señas 2'),
	   ('3-103-100003', 'Empresa 3', 'empresa3@example.com', 'Cartago', 'Canton3', 'Distrito3', 'Barrio3', 'Señas 3'),
	   ('3-104-100004', 'Empresa 4', 'empresa4@example.com', 'Heredia', 'Canton4', 'Distrito4', 'Barrio4', 'Señas 4'),
	   ('3-105-100005', 'Empresa 5', 'empresa5@example.com', 'Limón', 'Canton5', 'Distrito5', 'Barrio5', 'Señas 5'),
	   ('3-106-100006', 'Empresa 6', 'empresa6@example.com', 'San José', 'Canton6', 'Distrito6', 'Barrio6', 'Señas 6'),
	   ('3-107-100007', 'Empresa 7', 'empresa7@example.com', 'Alajuela', 'Canton7', 'Distrito7', 'Barrio7', 'Señas 7'),
	   ('3-108-100008', 'Empresa 8', 'empresa8@example.com', 'Cartago', 'Canton8', 'Distrito8', 'Barrio8', 'Señas 8'),
	   ('3-109-100009', 'Empresa 9', 'empresa9@example.com', 'Heredia', 'Canton9', 'Distrito9', 'Barrio9', 'Señas 9'),
	   ('3-110-100010', 'Empresa 10', 'empresa10@example.com', 'Limón', 'Canton10', 'Distrito10', 'Barrio10', 'Señas 10'),
	   ('3-111-100011', 'Empresa 11', 'empresa11@example.com', 'San José', 'Canton11', 'Distrito11', 'Barrio11', 'Señas 11'),
	   ('3-112-100012', 'Empresa 12', 'empresa12@example.com', 'Alajuela', 'Canton12', 'Distrito12', 'Barrio12', 'Señas 12'),
	   ('3-113-100013', 'Empresa 13', 'empresa13@example.com', 'Cartago', 'Canton13', 'Distrito13', 'Barrio13', 'Señas 13'),
	   ('3-114-100014', 'Empresa 14', 'empresa14@example.com', 'Heredia', 'Canton14', 'Distrito14', 'Barrio14', 'Señas 14'),
	   ('3-115-100015', 'Empresa 15', 'empresa15@example.com', 'Limón', 'Canton15', 'Distrito15', 'Barrio15', 'Señas 15');


-- ================================================
-- 2. Tabla Hospedaje 
-- ================================================
INSERT INTO Hospedaje (id_empresa, tipo_hospedaje, referencia_gps, enlace)
VALUES (1, 'Hotel', '9.91,-84.11', 'http://empresa1.com/hospedaje'),
	   (2, 'Casa', '9.92,-84.12', 'http://empresa2.com/hospedaje'),
	   (3, 'Departamento', '9.93,-84.13', 'http://empresa3.com/hospedaje'),
	   (4, 'Cuarto Compartido', '9.94,-84.14', 'http://empresa4.com/hospedaje'),
	   (5, 'Cabaña', '9.95,-84.15', 'http://empresa5.com/hospedaje'),
	   (6, 'Hotel', '9.96,-84.16', 'http://empresa6.com/hospedaje'),
	   (7, 'Casa', '9.97,-84.17', 'http://empresa7.com/hospedaje'),
	   (8, 'Departamento', '9.98,-84.18', 'http://empresa8.com/hospedaje'),
	   (9, 'Cuarto Compartido', '9.99,-84.19', 'http://empresa9.com/hospedaje'),
	   (10, 'Cabaña', '9.910,-84.110', 'http://empresa10.com/hospedaje'),
	   (11, 'Hotel', '9.911,-84.111', 'http://empresa11.com/hospedaje'),
	   (12, 'Casa', '9.912,-84.112', 'http://empresa12.com/hospedaje'),
	   (13, 'Departamento', '9.913,-84.113', 'http://empresa13.com/hospedaje'),
	   (14, 'Cuarto Compartido', '9.914,-84.114', 'http://empresa14.com/hospedaje'),
	   (15, 'Cabaña', '9.915,-84.115', 'http://empresa15.com/hospedaje');


-- ================================================
-- 3. Tabla Hospedaje_Telefono 
-- ================================================
INSERT INTO Hospedaje_Telefono (id_hospedaje, numero_telefonico)
VALUES 
  (1, '80000001'),
  (2, '80000002'),
  (3, '80000003'),
  (4, '80000004'),
  (5, '80000005'),
  (6, '80000006'),
  (7, '80000007'),
  (8, '80000008'),
  (9, '80000009'),
  (10, '80000010'),
  (11, '80000011'),
  (12, '80000012'),
  (13, '80000013'),
  (14, '80000014'),
  (15, '80000015');


-- ================================================
-- 4. Tabla Hospedaje_Servicio 
-- ================================================
INSERT INTO Hospedaje_Servicio (id_hospedaje, servicio)
VALUES 
  (1, 'Servicio 1'),
  (2, 'Servicio 2'),
  (3, 'Servicio 3'),
  (4, 'Servicio 4'),
  (5, 'Servicio 5'),
  (6, 'Servicio 6'),
  (7, 'Servicio 7'),
  (8, 'Servicio 8'),
  (9, 'Servicio 9'),
  (10, 'Servicio 10'),
  (11, 'Servicio 11'),
  (12, 'Servicio 12'),
  (13, 'Servicio 13'),
  (14, 'Servicio 14'),
  (15, 'Servicio 15');


-- ================================================
-- 5. Tabla Hospedaje_Red_Social 
-- ================================================
INSERT INTO Hospedaje_Red_Social (id_hospedaje, plataforma, enlace)
VALUES 
  (1, 'Facebook',   'http://red1.example.com'),
  (2, 'Instagram',  'http://red2.example.com'),
  (3, 'Facebook',   'http://red3.example.com'),
  (4, 'Instagram',  'http://red4.example.com'),
  (5, 'Facebook',   'http://red5.example.com'),
  (6, 'Instagram',  'http://red6.example.com'),
  (7, 'Facebook',   'http://red7.example.com'),
  (8, 'Instagram',  'http://red8.example.com'),
  (9, 'Facebook',   'http://red9.example.com'),
  (10, 'Instagram', 'http://red10.example.com'),
  (11, 'Facebook',  'http://red11.example.com'),
  (12, 'Instagram', 'http://red12.example.com'),
  (13, 'Facebook',  'http://red13.example.com'),
  (14, 'Instagram', 'http://red14.example.com'),
  (15, 'Facebook',  'http://red15.example.com');


-- ================================================
-- 6. Tabla Tipo_Habitacion 
-- ================================================
INSERT INTO Tipo_Habitacion (id_hospedaje, nombre, descripcion, tipo_cama, precio)
VALUES 
  (1, 'Habitacion 1', 'Descripcion de Habitacion 1', 'King', 110.00),
  (2, 'Habitacion 2', 'Descripcion de Habitacion 2', 'Queen', 120.00),
  (3, 'Habitacion 3', 'Descripcion de Habitacion 3', 'King', 130.00),
  (4, 'Habitacion 4', 'Descripcion de Habitacion 4', 'Queen', 140.00),
  (5, 'Habitacion 5', 'Descripcion de Habitacion 5', 'King', 150.00),
  (6, 'Habitacion 6', 'Descripcion de Habitacion 6', 'Queen', 160.00),
  (7, 'Habitacion 7', 'Descripcion de Habitacion 7', 'King', 170.00),
  (8, 'Habitacion 8', 'Descripcion de Habitacion 8', 'Queen', 180.00),
  (9, 'Habitacion 9', 'Descripcion de Habitacion 9', 'King', 190.00),
  (10, 'Habitacion 10', 'Descripcion de Habitacion 10', 'Queen', 200.00),
  (11, 'Habitacion 11', 'Descripcion de Habitacion 11', 'King', 210.00),
  (12, 'Habitacion 12', 'Descripcion de Habitacion 12', 'Queen', 220.00),
  (13, 'Habitacion 13', 'Descripcion de Habitacion 13', 'King', 230.00),
  (14, 'Habitacion 14', 'Descripcion de Habitacion 14', 'Queen', 240.00),
  (15, 'Habitacion 15', 'Descripcion de Habitacion 15', 'King', 250.00);


-- ================================================
-- 7. Tabla Tipo_Habitacion_Comodidad 
-- ================================================
INSERT INTO Tipo_Habitacion_Comodidad (id_tipo_habitacion, comodidad)
VALUES 
  (1, 'Comodidad 1'),
  (2, 'Comodidad 2'),
  (3, 'Comodidad 3'),
  (4, 'Comodidad 4'),
  (5, 'Comodidad 5'),
  (6, 'Comodidad 6'),
  (7, 'Comodidad 7'),
  (8, 'Comodidad 8'),
  (9, 'Comodidad 9'),
  (10, 'Comodidad 10'),
  (11, 'Comodidad 11'),
  (12, 'Comodidad 12'),
  (13, 'Comodidad 13'),
  (14, 'Comodidad 14'),
  (15, 'Comodidad 15');


-- ================================================
-- 8. Tabla Tipo_Habitacion_Foto 
-- ================================================
INSERT INTO Tipo_Habitacion_Foto (id_tipo_habitacion, foto)
VALUES 
  (1, 0xFFD8FFE000104A46494600010101006000600000),
  (2, 0xFFD8FFE000104A46494600010101006000600000),
  (3, 0xFFD8FFE000104A46494600010101006000600000),
  (4, 0xFFD8FFE000104A46494600010101006000600000),
  (5, 0xFFD8FFE000104A46494600010101006000600000),
  (6, 0xFFD8FFE000104A46494600010101006000600000),
  (7, 0xFFD8FFE000104A46494600010101006000600000),
  (8, 0xFFD8FFE000104A46494600010101006000600000),
  (9, 0xFFD8FFE000104A46494600010101006000600000),
  (10, 0xFFD8FFE000104A46494600010101006000600000),
  (11, 0xFFD8FFE000104A46494600010101006000600000),
  (12, 0xFFD8FFE000104A46494600010101006000600000),
  (13, 0xFFD8FFE000104A46494600010101006000600000),
  (14, 0xFFD8FFE000104A46494600010101006000600000),
  (15, 0xFFD8FFE000104A46494600010101006000600000);


-- ================================================
-- 9. Tabla Habitacion 
-- ================================================
INSERT INTO Habitacion (id_tipo_habitacion, numero)
VALUES 
  (1, '101'),
  (2, '102'),
  (3, '103'),
  (4, '104'),
  (5, '105'),
  (6, '106'),
  (7, '107'),
  (8, '108'),
  (9, '109'),
  (10, '110'),
  (11, '111'),
  (12, '112'),
  (13, '113'),
  (14, '114'),
  (15, '115');


-- ================================================
-- 10. Tabla Cliente 
-- ================================================
INSERT INTO Cliente (nombre, primer_apellido, segundo_apellido, fecha_nacimiento, tipo_identificacion, numero_identificacion, pais_residencia, correo_electronico, provincia, canton, distrito)
VALUES 
  ('Cliente1', 'Perez', 'Gomez', '1980-01-01', 'Cedula', '1-200-000001', 'Costa Rica', 'cliente1@example.com', 'San José', 'Central', 'Carmen'),
  ('Cliente2', 'Lopez', 'Martinez', '1981-02-02', 'Cedula', '1-200-000002', 'Costa Rica', 'cliente2@example.com', 'Alajuela', 'Central', 'San Carlos'),
  ('Cliente3', 'Sanchez', 'Rodriguez', '1982-03-03', 'Cedula', '1-200-000003', 'Costa Rica', 'cliente3@example.com', 'Cartago', 'Central', 'Carmen'),
  ('Cliente4', 'Diaz', 'Morales', '1983-04-04', 'Cedula', '1-200-000004', 'Costa Rica', 'cliente4@example.com', 'Heredia', 'Central', 'Santo Domingo'),
  ('Cliente5', 'Ramirez', 'Castro', '1984-05-05', 'Cedula', '1-200-000005', 'Costa Rica', 'cliente5@example.com', 'San José', 'Central', 'Carmen'),
  ('Cliente6', 'Mendez', 'Vargas', '1985-06-06', 'Cedula', '1-200-000006', 'Costa Rica', 'cliente6@example.com', 'Alajuela', 'Central', 'San Ramon'),
  ('Cliente7', 'Alvarado', 'Fuentes', '1986-07-07', 'Cedula', '1-200-000007', 'Costa Rica', 'cliente7@example.com', 'Cartago', 'Central', 'Turrialba'),
  ('Cliente8', 'Moreno', 'Soto', '1987-08-08', 'Cedula', '1-200-000008', 'Costa Rica', 'cliente8@example.com', 'Heredia', 'Central', 'Santo Domingo'),
  ('Cliente9', 'Castro', 'Rojas', '1988-09-09', 'Cedula', '1-200-000009', 'Costa Rica', 'cliente9@example.com', 'San José', 'Central', 'Carmen'),
  ('Cliente10', 'Vargas', 'Silva', '1989-10-10', 'Cedula', '1-200-000010', 'Costa Rica', 'cliente10@example.com', 'Alajuela', 'Central', 'San Ramon'),
  ('Cliente11', 'Rojas', 'Jimenez', '1990-11-11', 'Cedula', '1-200-000011', 'Costa Rica', 'cliente11@example.com', 'Cartago', 'Central', 'Carmen'),
  ('Cliente12', 'Ortiz', 'Castillo', '1991-12-12', 'Cedula', '1-200-000012', 'Costa Rica', 'cliente12@example.com', 'Heredia', 'Central', 'Santo Domingo'),
  ('Cliente13', 'Flores', 'Acosta', '1992-01-13', 'Cedula', '1-200-000013', 'Costa Rica', 'cliente13@example.com', 'San José', 'Central', 'Carmen'),
  ('Cliente14', 'Jimenez', 'Mora', '1993-02-14', 'Cedula', '1-200-000014', 'Costa Rica', 'cliente14@example.com', 'Alajuela', 'Central', 'San Ramon'),
  ('Cliente15', 'Morales', 'Delgado', '1994-03-15', 'Cedula', '1-200-000015', 'Costa Rica', 'cliente15@example.com', 'Cartago', 'Central', 'Carmen');


-- ================================================
-- 11. Tabla Cliente_Telefono 
-- ================================================
INSERT INTO Cliente_Telefono (id_cliente, numero_telefonico, codigo_pais)
VALUES 
  (1, '70000001', '506'),
  (2, '70000002', '506'),
  (3, '70000003', '506'),
  (4, '70000004', '506'),
  (5, '70000005', '506'),
  (6, '70000006', '506'),
  (7, '70000007', '506'),
  (8, '70000008', '506'),
  (9, '70000009', '506'),
  (10, '70000010', '506'),
  (11, '70000011', '506'),
  (12, '70000012', '506'),
  (13, '70000013', '506'),
  (14, '70000014', '506'),
  (15, '70000015', '506');


-- ================================================
-- 12. Tabla Reserva 
-- ================================================
INSERT INTO Reserva (id_cliente, id_habitacion, fecha_hora_ingreso, cantidad_personas, posee_vehiculo, fecha_salida, hora_salida)
VALUES 
  (1, 1, '2025-06-01 14:00:00', 2, 1, '2025-06-05', '12:00:00'),
  (2, 2, '2025-06-02 15:00:00', 3, 0, '2025-06-06', '12:00:00'),
  (3, 3, '2025-06-03 16:00:00', 4, 1, '2025-06-07', '12:00:00'),
  (4, 4, '2025-06-04 14:30:00', 2, 0, '2025-06-08', '12:00:00'),
  (5, 5, '2025-06-05 15:30:00', 3, 1, '2025-06-09', '12:00:00'),
  (6, 6, '2025-06-06 16:30:00', 4, 0, '2025-06-10', '12:00:00'),
  (7, 7, '2025-06-07 14:45:00', 2, 1, '2025-06-11', '12:00:00'),
  (8, 8, '2025-06-08 15:45:00', 3, 0, '2025-06-12', '12:00:00'),
  (9, 9, '2025-06-09 16:45:00', 4, 1, '2025-06-13', '12:00:00'),
  (10, 10, '2025-06-10 14:15:00', 2, 0, '2025-06-14', '12:00:00'),
  (11, 11, '2025-06-11 15:15:00', 3, 1, '2025-06-15', '12:00:00'),
  (12, 12, '2025-06-12 16:15:00', 4, 0, '2025-06-16', '12:00:00'),
  (13, 13, '2025-06-13 14:30:00', 2, 1, '2025-06-17', '12:00:00'),
  (14, 14, '2025-06-14 15:30:00', 3, 0, '2025-06-18', '12:00:00'),
  (15, 15, '2025-06-15 16:30:00', 4, 1, '2025-06-19', '12:00:00');


-- ================================================
-- 13. Tabla Facturacion 
-- ================================================
INSERT INTO Facturacion (id_reserva, numero_noches, importe_total, tipo_pago, fecha_factura)
VALUES 
  (1, 4, 400.00, 'Tarjeta', '2025-06-06'),
  (2, 4, 420.00, 'Efectivo', '2025-06-07'),
  (3, 4, 440.00, 'Tarjeta', '2025-06-08'),
  (4, 4, 460.00, 'Efectivo', '2025-06-09'),
  (5, 4, 480.00, 'Tarjeta', '2025-06-10'),
  (6, 4, 500.00, 'Efectivo', '2025-06-11'),
  (7, 4, 520.00, 'Tarjeta', '2025-06-12'),
  (8, 4, 540.00, 'Efectivo', '2025-06-13'),
  (9, 4, 560.00, 'Tarjeta', '2025-06-14'),
  (10, 4, 580.00, 'Efectivo', '2025-06-15'),
  (11, 4, 600.00, 'Tarjeta', '2025-06-16'),
  (12, 4, 620.00, 'Efectivo', '2025-06-17'),
  (13, 4, 640.00, 'Tarjeta', '2025-06-18'),
  (14, 4, 660.00, 'Efectivo', '2025-06-19'),
  (15, 4, 680.00, 'Tarjeta', '2025-06-20');


-- ================================================
-- 14. Tabla Recreacion 
-- ================================================
INSERT INTO Recreacion (id_empresa, precio, telefono, nombre_contacto, descripcion_actividad)
VALUES 
  (1, 55.00, '90000001', 'Contacto R1', 'Actividad de aventura 1'),
  (2, 60.00, '90000002', 'Contacto R2', 'Actividad de aventura 2'),
  (3, 65.00, '90000003', 'Contacto R3', 'Actividad de aventura 3'),
  (4, 70.00, '90000004', 'Contacto R4', 'Actividad de aventura 4'),
  (5, 75.00, '90000005', 'Contacto R5', 'Actividad de aventura 5'),
  (6, 80.00, '90000006', 'Contacto R6', 'Actividad de aventura 6'),
  (7, 85.00, '90000007', 'Contacto R7', 'Actividad de aventura 7'),
  (8, 90.00, '90000008', 'Contacto R8', 'Actividad de aventura 8'),
  (9, 95.00, '90000009', 'Contacto R9', 'Actividad de aventura 9'),
  (10, 100.00, '90000010', 'Contacto R10', 'Actividad de aventura 10'),
  (11, 105.00, '90000011', 'Contacto R11', 'Actividad de aventura 11'),
  (12, 110.00, '90000012', 'Contacto R12', 'Actividad de aventura 12'),
  (13, 115.00, '90000013', 'Contacto R13', 'Actividad de aventura 13'),
  (14, 120.00, '90000014', 'Contacto R14', 'Actividad de aventura 14'),
  (15, 125.00, '90000015', 'Contacto R15', 'Actividad de aventura 15');


-- ================================================
-- 15. Tabla Recreacion_Tipo_Actividad 
-- ================================================
INSERT INTO Recreacion_Tipo_Actividad (id_recreacion, tipo_actividad)
VALUES 
  (1, 'Actividad A1'),
  (2, 'Actividad A2'),
  (3, 'Actividad A3'),
  (4, 'Actividad A4'),
  (5, 'Actividad A5'),
  (6, 'Actividad A6'),
  (7, 'Actividad A7'),
  (8, 'Actividad A8'),
  (9, 'Actividad A9'),
  (10, 'Actividad A10'),
  (11, 'Actividad A11'),
  (12, 'Actividad A12'),
  (13, 'Actividad A13'),
  (14, 'Actividad A14'),
  (15, 'Actividad A15');


-- ================================================
-- 16. Tabla Recreacion_Tipo_Servicio 
-- ================================================
INSERT INTO Recreacion_Tipo_Servicio (id_recreacion, tipo_servicio)
VALUES 
  (1, 'Servicio R1'),
  (2, 'Servicio R2'),
  (3, 'Servicio R3'),
  (4, 'Servicio R4'),
  (5, 'Servicio R5'),
  (6, 'Servicio R6'),
  (7, 'Servicio R7'),
  (8, 'Servicio R8'),
  (9, 'Servicio R9'),
  (10, 'Servicio R10'),
  (11, 'Servicio R11'),
  (12, 'Servicio R12'),
  (13, 'Servicio R13'),
  (14, 'Servicio R14'),
  (15, 'Servicio R15');



-- La salida debería mostrar los registros consolidados de la vista Resumen_Hospedaje.

/*
SELECT * FROM Resumen_Hospedaje;
SELECT * FROM Empresa; 
SELECT * FROM Hospedaje;            
SELECT * FROM Hospedaje_Telefono;
SELECT * FROM Hospedaje_Servicio;
SELECT * FROM Hospedaje_Red_Social;
*/

-- Caso de prueba 1: Insertar un nuevo hospedaje
EXEC sp_Insertar_Hospedaje
    @cedula_juridica = '3-101-111111',
    @nombre_empresa = 'Hotel Test 1',
    @correo_electronico = 'test1@hotel.com',
    @provincia = 'San José',
    @canton = 'Central',
    @distrito = 'Carmen',
    @barrio = 'Centro',
    @senias_exactas = 'Av. Principal 100',
    @tipo_hospedaje = 'Hotel',
    @referencia_gps = '9.91,-84.11',
    @enlace = 'http://hoteltest1.com',
    @numero_telefonico = '80011111',
    @servicio = 'Piscina',
    @plataforma = 'Facebook',
    @red_enlace = 'http://facebook.com/hoteltest1';


SELECT * FROM Empresa WHERE cedula_juridica = '3-101-111111';
SELECT * FROM Hospedaje WHERE 
	id_empresa = (SELECT TOP 1 id_empresa FROM Empresa WHERE cedula_juridica = '3-101-111111');
SELECT * FROM Hospedaje_Telefono WHERE
	id_hospedaje = (SELECT TOP 1 id_hospedaje FROM Hospedaje ORDER BY id_hospedaje DESC);
SELECT * FROM Hospedaje_Servicio WHERE
	id_hospedaje = (SELECT TOP 1 id_hospedaje FROM Hospedaje ORDER BY id_hospedaje DESC);
SELECT * FROM Hospedaje_Red_Social WHERE
	id_hospedaje = (SELECT TOP 1 id_hospedaje FROM Hospedaje ORDER BY id_hospedaje DESC);


-- Caso de prueba 2: Actualizar el correo y la referencia GPS del hospedaje
EXEC sp_Actualizar_Hospedaje
    @id_empresa = 16,
    @id_hospedaje = 16,
    @cedula_juridica = NULL,         -- no actualizamos
    @nombre_empresa = NULL,
    @correo_electronico = 'nuevo_contacto@hoteltest1.com',
    @provincia = NULL,
    @canton = NULL,
    @distrito = NULL,
    @barrio = NULL,
    @senias_exactas = NULL,
    @tipo_hospedaje = NULL,
    @referencia_gps = '9.99,-84.99',
    @enlace = NULL;


SELECT * FROM Empresa WHERE id_empresa = 16;
SELECT * FROM Hospedaje WHERE id_hospedaje = 16;

-- Caso de prueba 3: Buscar hospedajes en "San José" filtrando por provincia
EXEC sp_Buscar_Hospedaje
    @provincia = 'San José', 
    @tipo_hospedaje = NULL;

-- Caso de prueba 4: Eliminar el hospedaje insertado (id_hospedaje = 16)
EXEC sp_Eliminar_Hospedaje @id_hospedaje = 16;


SELECT * FROM Hospedaje WHERE id_hospedaje = 16;
SELECT * FROM Empresa WHERE id_empresa = 16;

-- Caso de prueba 5: Insertar un tipo de habitación para un hospedaje existente (por ejemplo, id_hospedaje = 2)
EXEC sp_Insertar_Tipo_Habitacion
    @id_hospedaje = 2,
    @nombre = 'Suite Test',
    @descripcion = 'Suite de prueba con vista panorámica.',
    @tipo_cama = 'King',
    @precio = 175.00;


SELECT * FROM Tipo_Habitacion WHERE id_hospedaje = 2;

-- Caso de prueba 6: Actualizar la descripción y el precio del tipo de habitación
EXEC sp_Actualizar_Tipo_Habitacion
    @id_tipo_habitacion = 16,
    @id_hospedaje = NULL,
    @nombre = NULL,
    @descripcion = 'Suite Test actualizada con vista ampliada.',
    @tipo_cama = NULL,
    @precio = 185.00;


SELECT * FROM Tipo_Habitacion WHERE id_tipo_habitacion = 16;

-- Caso de prueba 7: Eliminar el tipo de habitación con id_tipo_habitacion = 16
EXEC sp_Eliminar_Tipo_Habitacion @id_tipo_habitacion = 16;


SELECT * FROM Tipo_Habitacion WHERE id_tipo_habitacion = 16;

-- Insertar Comodidad
EXEC sp_Insertar_Tipo_Habitacion_Comodidad
    @id_tipo_habitacion = 2,
    @comodidad = 'Wi-Fi Gratis';


SELECT * FROM Tipo_Habitacion_Comodidad WHERE id_tipo_habitacion = 2;

-- Actualizar Comodidad (suponiendo id_comodidad = 1)
EXEC sp_Actualizar_Tipo_Habitacion_Comodidad
    @id_comodidad = 1,
    @id_tipo_habitacion = NULL,
    @comodidad = 'Wi-Fi Ultra Rápido';


SELECT * FROM Tipo_Habitacion_Comodidad WHERE id_comodidad = 1;

-- Eliminar Comodidad
EXEC sp_Eliminar_Tipo_Habitacion_Comodidad @id_comodidad = 1;
SELECT * FROM Tipo_Habitacion_Comodidad WHERE id_comodidad = 1;


-- Insertar Foto
EXEC sp_Insertar_Tipo_Habitacion_Foto
    @id_tipo_habitacion = 2,
    @foto = 0xFFD8FFE000104A46494600010101006000600000;


SELECT * FROM Tipo_Habitacion_Foto WHERE id_tipo_habitacion = 2;

-- Actualizar Foto (suponiendo id_foto = 1)
EXEC sp_Actualizar_Tipo_Habitacion_Foto
    @id_foto = 1,
    @id_tipo_habitacion = NULL,
    @foto = 0xFFD8FFE000104A46494600010101006000600001;


SELECT * FROM Tipo_Habitacion_Foto WHERE id_foto = 1;

-- Eliminar Foto
EXEC sp_Eliminar_Tipo_Habitacion_Foto @id_foto = 1;
SELECT * FROM Tipo_Habitacion_Foto WHERE id_foto = 1;

-- Insertar Habitación
EXEC sp_Insertar_Habitacion
    @id_tipo_habitacion = 2,
    @numero = '201';


SELECT * FROM Habitacion WHERE id_tipo_habitacion = 2;

-- Actualizar Habitación (suponiendo id_habitacion = 16)
EXEC sp_Actualizar_Habitacion
    @id_habitacion = 16,
    @id_tipo_habitacion = NULL,
    @numero = '202';

SELECT * FROM Habitacion WHERE id_habitacion = 16;

-- Eliminar Habitación
EXEC sp_Eliminar_Habitacion @id_habitacion = 16;
SELECT * FROM Habitacion WHERE id_habitacion = 16;

-- Caso de prueba 8: Insertar un registro en Recreación
EXEC sp_Insertar_Recreacion
    @cedula_juridica = '3-201-999888',
    @nombre_empresa = 'Recreo Test',
    @correo_electronico = 'info@recreotest.com',
    @provincia = 'Cartago',
    @canton = 'Central',
    @distrito = 'Carmen',
    @barrio = 'Centro',
    @senias_exactas = 'Calle 45, Edificio Recreo',
    @precio = 85.50,
    @telefono = '90012345',
    @nombre_contacto = 'Ana López',
    @descripcion_actividad = 'Tour de aventura en bote';


SELECT * FROM Empresa WHERE cedula_juridica = '3-201-999888';
SELECT * FROM Recreacion WHERE id_empresa = (SELECT TOP 1 id_empresa FROM Empresa WHERE cedula_juridica = '3-201-999888');

-- Caso de prueba 9: Actualizar únicamente el precio y teléfono de Recreación
EXEC sp_Actualizar_Recreacion
    @id_empresa = 17,
    @id_recreacion = 16,
    @precio = 90.00,
    @telefono = '90054321',
    @cedula_juridica = NULL,
    @nombre_empresa = NULL,
    @correo_electronico = NULL,
    @provincia = NULL,
    @canton = NULL,
    @distrito = NULL,
    @barrio = NULL,
    @senias_exactas = NULL,
    @nombre_contacto = NULL,
    @descripcion_actividad = NULL;


SELECT * FROM Empresa WHERE id_empresa = 17;
SELECT * FROM Recreacion WHERE id_recreacion = 16;

-- Caso de prueba 10: Eliminar el Recreación con id_recreacion = 16
EXEC sp_Eliminar_Recreacion @id_recreacion = 16;


SELECT * FROM Recreacion WHERE id_recreacion = 16;
SELECT * FROM Empresa WHERE id_empresa = 17;

-- Caso de prueba 11: Buscar recreaciones con precio entre 80 y 100 y en Cartago
EXEC sp_Buscar_Recreacion
    @provincia = 'Cartago',
    @precio_min = 80,
    @precio_max = 100;

-- Caso de prueba 12: Insertar un Cliente
EXEC sp_Insertar_Cliente
    @nombre = 'Luis',
    @primer_apellido = 'Ramirez',
    @segundo_apellido = 'Mena',
    @fecha_nacimiento = '1985-07-20',
    @tipo_identificacion = 'Cedula',
    @numero_identificacion = '1-300-000001',
    @pais_residencia = 'Costa Rica',
    @correo_electronico = 'luis.ramirez@example.com',
    @provincia = 'Heredia',
    @canton = 'Central',
    @distrito = 'Santo Domingo';


SELECT * FROM Cliente WHERE numero_identificacion = '1-300-000001';

-- Caso de prueba 13: Actualizar el correo y la provincia del Cliente 
EXEC sp_Actualizar_Cliente
    @id_cliente = 16,
    @correo_electronico = 'luis.nuevo@example.com',
    @provincia = 'San José';

SELECT * FROM Cliente WHERE id_cliente = 16;

-- Caso de prueba 14: Insertar un teléfono para el Cliente 
EXEC sp_Insertar_Cliente_Telefono
    @id_cliente = 16,
    @numero_telefonico = '70001234',
    @codigo_pais = '506';

SELECT * FROM Cliente_Telefono WHERE id_cliente = 16;

-- Actualizar el teléfono 
EXEC sp_Actualizar_Cliente_Telefono
    @id_telefono = 1,
    @numero_telefonico = '70005678';

SELECT * FROM Cliente_Telefono WHERE id_telefono = 1;

-- Eliminar el registro
EXEC sp_Eliminar_Cliente_Telefono @id_telefono = 1;

SELECT * FROM Cliente_Telefono WHERE id_telefono = 1;

-- Caso de prueba 15: Eliminar el Cliente (suponiendo id_cliente = 16)
EXEC sp_Eliminar_Cliente @id_cliente = 16;

SELECT * FROM Cliente WHERE id_cliente = 16;
SELECT * FROM Cliente_Telefono WHERE id_cliente = 16;


-- Caso de prueba 16: Insertar una Reserva
EXEC sp_Insertar_Reserva
    @id_cliente = 2,
    @id_habitacion = 5,
    @fecha_hora_ingreso = '2025-07-01 14:00:00',
    @cantidad_personas = 2,
    @posee_vehiculo = 1,
    @fecha_salida = '2025-07-05',
    @hora_salida = '12:00:00';

SELECT * FROM Reserva;

EXEC sp_Actualizar_Reserva
    @id_reserva = 1,
    @cantidad_personas = 3,
    @fecha_salida = '2025-07-06';

SELECT * FROM Reserva WHERE id_reserva = 1;

/*
-- Caso de prueba 18: Eliminar la Reserva (suponiendo id_reserva = 1)
EXEC sp_Eliminar_Reserva @id_reserva = 1;

SELECT * FROM Reserva WHERE id_reserva = 1;
*/

-- Caso de prueba 19: Buscar reservas 
EXEC sp_Buscar_Reserva
    @provincia = 'San José',
    @tipo_hospedaje = NULL,
    @fecha_ingreso_inicio = '2025-07-01',
    @fecha_ingreso_fin = '2025-07-31',
    @cantidad_personas = 2,
    @posee_vehiculo = 1;

-- Caso de prueba 20: Insertar una Facturación 
EXEC sp_Insertar_Facturacion
    @id_reserva = 2,
    @numero_noches = 4,
    @importe_total = 450.00,
    @tipo_pago = 'Tarjeta',
    @fecha_factura = '2025-07-06';


SELECT * FROM Facturacion;

-- Caso de prueba 21: Actualizar la facturación 
EXEC sp_Actualizar_Facturacion
    @id_facturacion = 1,
    @importe_total = 460.00,
    @tipo_pago = 'Efectivo';

SELECT * FROM Facturacion WHERE id_facturacion = 1;

-- Caso de prueba 22: Eliminar la facturación 
EXEC sp_Eliminar_Facturacion @id_facturacion = 1;

SELECT * FROM Facturacion WHERE id_facturacion = 1;

-- Caso de prueba 23: Buscar facturación 
EXEC sp_Buscar_Facturacion
    @id_habitacion = 5;



