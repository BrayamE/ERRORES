--BRAYAM EDWIN QUISPE APAZA
CREATE PROCEDURE CrearCliente(
	@PersonaID INT,
	@Mensaje NVARCHAR(200) OUTPUT,
	@Error INT OUTPUT
	)
AS
BEGIN
	BEGIN TRY
		BEGIN TRANSACTION;

		SET @Mensaje='';
		SET @Error=0;
		--DECLARAR
		DECLARE @FechaNacimiento DATE;
        DECLARE @NumeroDOC INT;
        DECLARE @Nombre NVARCHAR(50);
        DECLARE @ApellidoPaterno NVARCHAR(50);
        DECLARE @ApellidoMaterno NVARCHAR(50);
        DECLARE @Direccion NVARCHAR(100);
        DECLARE @Email NVARCHAR(100);

        SELECT 
            @FechaNacimiento = FechaNacimiento,
            @NumeroDOC = NumeroDOC,
            @Nombre = Nombre,
            @ApellidoPaterno = ApellidoPaterno,
            @ApellidoMaterno = ApellidoMaterno,
            @Direccion = Direccion,
            @Email = Email
        FROM Personas WHERE PersonaID = @PersonaID;

		--VALIDACIONES
		--FECHA NACIMIENTO
		IF @FechaNacimiento >= GETDATE()
		BEGIN
			SET @Mensaje = 'La fecha de nacimiento debe ser anterior a la fecha actual.';
			SET @Error = 1;
			THROW 51001, @Mensaje, 25;
		END;
		--DEBE TENER NUMERODOC
		IF @NumeroDOC IS NULL
		BEGIN
			SET @Mensaje = 'La persona no tiene documento';
			SET @Error = 1;
			THROW 51002, @Mensaje, 32;
		END;
		--El documento debe tener 8 Caracteres
		IF LEN(@NumeroDOC) <> 8
		BEGIN
			SET @Mensaje = 'El número de documento debe tener 8 caracteres.';
			SET @Error = 1;
			THROW 51003, @Mensaje, 39;
		END;
		--Si el cliente ya esta registrado.
		IF EXISTS (SELECT 1 FROM Clientes WHERE PersonaID = @PersonaID)
		BEGIN
			SET @Mensaje = 'El cliente ya está registrado.';
			SET @Error = 1;
			THROW 51004, @Mensaje, 25;

		END;

		--Si Persona no existe.
		IF NOT EXISTS (SELECT 1 FROM Clientes WHERE PersonaID = @PersonaID)
		BEGIN
			SET @Mensaje = 'La persona no existe.';
			SET @Error = 1;
		THROW 51003, @Mensaje, 25;
		END;
		--El cliente debe ser Mayor de edad (>18)
		IF DATEADD(YEAR, 18, @FechaNacimiento) > GETDATE()
		BEGIN
			SET @Mensaje = 'El cliente debe ser mayor de edad.';
			SET @Error = 1;
			THROW 51001, @Mensaje, 25;
		END;

		--Debe tener una Dirección.
		IF NOT EXISTS (SELECT 1 FROM Clientes WHERE PersonaID = @PersonaID)
		BEGIN
			SET @Mensaje = 'Debe ingresar una dirección para el cliente.';
			SET @Error = 1;
			THROW 51001, @Mensaje, 25;
		END;

		--Debe tener un Correo en siguente Formato(nombre.ApellidoPaterno o ApellidoMaterno)
		IF NOT (
            @Email LIKE '%.%'
            AND
            (
                @Email LIKE @Nombre + '.%'
                OR
                @Email LIKE @Nombre + '.' + @ApellidoPaterno
                OR
                @Email LIKE @Nombre + '.' + @ApellidoMaterno
            )
        )
        BEGIN
            SET @Mensaje = 'El correo electrónico debe estar en el formato (nombre.ApellidoPaterno o nombre.ApellidoMaterno)';
            SET @Error = 1;
            THROW 51001, @Mensaje, 25;
        END;

		COMMIT;
	END TRY
	BEGIN CATCH
		PRINT 'ERROR MENSAGE: '+ ERROR_MESSAGE();
		PRINT 'ERROR NUMERO: '+ CAST(ERROR_NUMBER() AS NVARCHAR(10));
		PRINT 'ERROR LINEA: '+ CAST(ERROR_STATE() AS NVARCHAR(10));

		ROLLBACK;
	END CATCH
END;

DECLARE @PersonaID INT;
DECLARE @Mensaje NVARCHAR(200);
DECLARE @Error INT;

SET @PersonaID = 2;
EXEC CrearCliente
	@PersonaID,
	@Mensaje OUTPUT,
	@Error OUTPUT;

IF @Error = 0
BEGIN
	PRINT 'OPERACION EXITOSA'
END
ELSE
BEGIN
	PRINT 'ERROR: ' + @Mensaje;
END;