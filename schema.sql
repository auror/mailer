create table users (
	id int(100) unsigned AUTO_INCREMENT primary key not null,
	name varchar(100) not null,
	email varchar(100) not null,
	password varchar(100) not null
);

insert into users (name, email, password) values ('name1', 'email1@yo.com', 'pass1');
insert into users (name, email, password) values ('name2', 'email2@yo.com', 'pass2');
insert into users (name, email, password) values ('name3', 'email3@yo.com', 'pass3');

create table emails (
	id int(100) unsigned AUTO_INCREMENT primary key not null,
	sender varchar(50) not null,
	receivers text not null,
	body text not null,
	created_at timestamp default current_timestamp
);

create table email_threads (
	id int(100) unsigned AUTO_INCREMENT primary key not null,
	thread_type int(1) default 0 not null,
	last_email_epoch timestamp not null,
	user_id int(100) unsigned not null,
	email_thread_group_id int(100) unsigned not null
);

create table email_thread_groups (
	id int(100) unsigned AUTO_INCREMENT primary key not null,
	subject text not null
);

create table email_thread_labels (
	id int(100) unsigned AUTO_INCREMENT primary key not null,
	label_id int(100) unsigned not null,
	email_thread_id int(100) unsigned not null
);

create table labels (
	id int(100) unsigned AUTO_INCREMENT primary key not null,
	description text not null
);

insert into labels (description) values ('inbox');
insert into labels (description) values ('sent');
insert into labels (description) values ('drafts');
insert into labels (description) values ('trash');

create table mailboxes (
	id int(100) unsigned AUTO_INCREMENT primary key not null,
	is_read tinyint(1) default 0 not null,
	email_id int(100) unsigned not null,
	email_thread_id int(100) unsigned not null,
	created_at timestamp default current_timestamp
);

ALTER TABLE mailboxes
add column created_at timestamp default current_timestamp
;

ALTER TABLE mailboxes
add column is_deleted tinyint(1) default 0,
add column is_draft tinyint(1) default 0
;

ALTER TABLE email_thread_labels
add column is_deleted tinyint(1) default 0
;
