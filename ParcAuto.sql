create database bd_parcauto
use bd_parcauto

create table Parc(
	id_parc int identity(1,1) primary key,
	nume varchar(35)
)

drop table Parc

insert into Parc values('Cluj')
insert into Parc values('Suceava')
insert into Parc values('Bacau')

update Parc
set nume = 'Rahova'
where id_parc>1

select * from Parc

CREATE TABLE Vanzator(
	id_vanz int identity(1,1) primary key,
	nume varchar(120),
	nr_masini_v int,
	id_parc int foreign key references Parc(id_parc)
	on delete cascade
	on update cascade
)

drop table Vanzator

insert into Vanzator values('Mircea' , 3, 1)
insert into Vanzator values('Doru', 18, 2)

update Vanzator
set nr_masini_v = 17
where nr_masini_v is NULL

select * from Vanzator

create table Cumparator(
     id_cump int primary key,
	 nume varchar(120),
	 buget int,
)

insert into Cumparator values(1, 'Tudor', 49000)
insert into Cumparator values(2, 'Alex', 55000)
insert into Cumparator values(3, 'Alex', 160000)

update Cumparator
set nume = 'Mihnea'
where id_cump = 2

delete from Cumparator where nume='Tudor'

select * from Cumparator

create table ContractV(
	id_vanz int foreign key references Vanzator(id_vanz)
	on delete cascade
	on update cascade,
	id_cump int foreign key references Cumparator(id_cump)
	on delete cascade
	on update cascade,
	constraint pk_contractv primary key(id_vanz, id_cump)
)

drop table ContractV

insert into ContractV values(1, 1)
insert into ContractV values(2, 3)

select * from ContractV


CREATE TABLE Masina(
	id_masina int primary key,
	marca varchar(50),
	model varchar(40),
	an int,
	pret int,
	id_cump int foreign key references Cumparator(id_cump)
	on delete cascade
	on update cascade
)

insert into Masina values(1, 'BMW', 'M3 F80', 2016, 44000, 1)
insert into Masina values(2, 'BMW', 'M8 COMP', 2020, 120000, 2)
insert into Masina values(3, 'Audi', 'RSQ8', 2021, 135000, 3)
insert into Masina values(4, 'BMW', 'M130i', 2016, 35500, 1)

update Masina
set model='M4 F82'
where marca='BMW' and an = 2016 

select * from Masina

select * from Parc
select * from Vanzator
select * from Cumparator
select * from ContractV
select * from  Masina


 ---- laborator 3 ----

 --- union ---
select nume from Cumparator
union
select nume from Vanzator

 --- inner join ---
select M.marca, M.model, C.nume as nume_cumparator, V.nume as nume_vanzator
from ContractV CV
inner join Masina M on CV.id_cump = M.id_cump
inner join Cumparator C on CV.id_cump = C.id_cump
inner join Vanzator V on CV.id_vanz = V.id_vanz


select M.marca, M.model, V.nume as nume_vanzator, P.nume as nume_parc
from Masina M
inner join ContractV CV on M.id_cump = CV.id_cump
inner join Vanzator V on CV.id_vanz = V.id_vanz
inner join Parc P on V.id_parc = P.id_parc

 --- left join ---
select P.nume as nume_parc, V.nume as nume_vanzator
from Parc P
left join Vanzator V on P.id_parc = V.id_parc
left join ContractV CV on V.id_vanz = CV.id_vanz

select AVG(pret) as pret_mediu_masina
from Masina M

 --- group by ---
select V.id_vanz, V.nume as nume_vanzator, count(M.id_masina) as numar_masini_vandute
from Vanzator V
left join ContractV CV on V.id_vanz = CV.id_vanz
left join Masina M on CV.id_cump = M.id_cump
group by V.id_vanz, V.nume
having count(M.id_masina) > 0 and count(M.id_masina) < 5

select an, SUM(pret) as suma_preturi
From Masina
group by an

select P.nume as nume_parc, count(V.id_vanz) as numar_vanzatori
from Parc P
left join Vanzator V on P.id_parc = V.id_parc
group by P.nume

--- bonus ---
select nume as nume_cumparator
from Cumparator
where id_cump in(
	select id_cump
	from Masina
	where an = 2016
)

select nume as nume_vanzator
from Vanzator V
where exists(
	select 1
	From ContractV CV
	where CV.id_vanz = V.id_vanz
)

 ---- laborator 4 ----

--create procedure getMasina
--@marca varchar(50)
--as begin
--select model,an,pret from Masina
--where marca = @marca
--end
--go
--exec getMasina 'BMW'

-- Crearea procedurii stocate pentru adăugarea datelor în tabelul Parc
create procedure AdaugaInParc @nume_parc varchar(35)
as
--begin
	if @nume_parc != 'botosani'
	begin
		insert into Parc values (@nume_parc)
	end
	else
	begin
		raiserror('Numele parcului nu este permis',1,1)
	end
--end
go

drop procedure AdaugaInParc

exec AdaugaInParc @nume_parc = 'mirauti'

delete from Parc where id_parc = 7
select *from Parc


-- Crearea procedurii stocate pentru adăugarea datelor în tabelul Vanzator
create procedure AdaugaInVanzator
    @nume_vanz varchar(120),
    @nr_masini int,
    @id_parc_v int
as
    if @nr_masini < 20
    begin
        insert into Vanzator values (@nume_vanz, @nr_masini, @id_parc_v);
    end
    else
    begin
        raiserror('In parc sunt prea multe masini.',1,1)
    end
go
drop procedure AdaugaInVanzator

exec AdaugaInVanzator @nume_vanz = 'Mihai', @nr_masini = 2,@id_parc_v =  2

select *from Vanzator

-- Crearea procedurii stocate pentru adăugarea datelor în tabelul ContractV
create procedure AdaugaInContractV
    @id_vanzator_cv int,
    @id_cumparator_cv int
as
    if exists (select * from Vanzator where id_vanz = @id_vanzator_cv) and exists (select * from Cumparator where id_cump = @id_cumparator_cv)
    begin
        insert into ContractV values (@id_vanzator_cv, @id_cumparator_cv);
    end
    else
    begin
        raiserror('ID-ul vânzătorului sau al cumpărătorului nu există.',1,1)
    end
go 

select *from Vanzator
select *from Cumparator
select *from ContractV

exec AdaugaInContractV @id_vanzator_cv = 5, @id_cumparator_cv = 3 

drop procedure AdaugaInContractV


--- view ---
create view VanzCump as
select 
	Vanzator.id_vanz as id_vanz,
	Vanzator.nume as nume_vanzataor,
	Vanzator.nr_masini_v as nr_vanzari,
	Cumparator.id_cump as id_cump,
	Cumparator.nume as nume_cumparator,
	Cumparator.buget as buget
from 
	Vanzator
join
	Cumparator on Vanzator.id_vanz = Cumparator.id_cump;

select *from VanzCump


 --- trigger pentru operatia delete ---
create trigger trg_Stergere_Parc
 on Parc
 after delete
 as
 begin
	declare @data_ora varchar(50)
	set @data_ora = CONVERT(varchar(20), getdate(), 120)

	print 'Data si ora operatiei: ' + @data_ora + ' | Tip operatie: DELETE | Nume tabel: Parc'
end 
go

delete from Parc where id_parc = 8

  --- trigger pentru operatia insert ---
create trigger trg_Inserare_Parc
 on Parc
 after insert
 as
 begin
	declare @data_ora varchar(50)
	set @data_ora = CONVERT(varchar(20), getdate(), 120)

	print 'Data si ora operatiei: ' + @data_ora + ' | Tip operatie: Insert | Nume tabel: Parc'
end 
go
select *from Masina

