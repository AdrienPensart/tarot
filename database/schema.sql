drop schema tarot cascade;
create schema if not exists tarot;

drop type if exists tarot.color_text;
create type tarot.color_text as enum ('pique', 'carreau', 'coeur', 'trefle', 'atout');
drop type if exists tarot.color_symbol;
create type tarot.color_symbol as enum ('♠', '♦', '♥', '♣', '🂠');

-- 1 pique = 1...K pique = 14, 1 carreau = 15...K carreau = 28, 1 coeur = 29...K coeur = 42
-- 1 trefle = 43...K trefle = 56, excuse = 56, 1 atout = 57...21 atout = 78

create table if not exists tarot.card (
    id smallint primary key,
    color varchar(1) not null,
    value smallint not null,
    points float not null,
    constraint value_range check ((color = '🂠' and value between 0 AND 21) or (value between 1 and 14)),
    constraint points_range check(
        (color = '🂠' and ((value in (0, 1, 21) and points = 4.5) or (value between 2 and 20 and points = 0.5))) or
        (color != '🂠' and (
            (value = 11 and points = 1.5) or
            (value = 12 and points = 2.5) or
            (value = 13 and points = 3.5) or
            (value = 14 and points = 4.5) or
            (value between 1 and 10 and points = 0.5 ))
        )),
    unique(color, value, points)
);
insert into tarot.card (id, color, value, points)
values
    (1, '♠', 1, 0.5),   (15, '♦', 1, 0.5),  (29, '♥', 1, 0.5),  (43, '♣', 1, 0.5),
    (2, '♠', 2, 0.5),   (16, '♦', 2, 0.5),  (30, '♥', 2, 0.5),  (44, '♣', 2, 0.5),
    (3, '♠', 3, 0.5),   (17, '♦', 3, 0.5),  (31, '♥', 3, 0.5),  (45, '♣', 3, 0.5),
    (4, '♠', 4, 0.5),   (18, '♦', 4, 0.5),  (32, '♥', 4, 0.5),  (46, '♣', 4, 0.5),
    (5, '♠', 5, 0.5),   (19, '♦', 5, 0.5),  (33, '♥', 5, 0.5),  (47, '♣', 5, 0.5),
    (6, '♠', 6, 0.5),   (20, '♦', 6, 0.5),  (34, '♥', 6, 0.5),  (48, '♣', 6, 0.5),
    (7, '♠', 7, 0.5),   (21, '♦', 7, 0.5),  (35, '♥', 7, 0.5),  (49, '♣', 7, 0.5),
    (8, '♠', 8, 0.5),   (22, '♦', 8, 0.5),  (36, '♥', 8, 0.5),  (50, '♣', 8, 0.5),
    (9, '♠', 9, 0.5),   (23, '♦', 9, 0.5),  (37, '♥', 9, 0.5),  (51, '♣', 9, 0.5),
    (10, '♠', 10, 0.5), (24, '♦', 10, 0.5), (38, '♥', 10, 0.5), (52, '♣', 10, 0.5),
    (11, '♠', 11, 1.5), (25, '♦', 11, 1.5), (39, '♥', 11, 1.5), (53, '♣', 11, 1.5),
    (12, '♠', 12, 2.5), (26, '♦', 12, 2.5), (40, '♥', 12, 2.5), (54, '♣', 12, 2.5),
    (13, '♠', 13, 3.5), (27, '♦', 13, 3.5), (41, '♥', 13, 3.5), (55, '♣', 13, 3.5),
    (14, '♠', 14, 4.5), (28, '♦', 14, 4.5), (42, '♥', 14, 4.5), (56, '♣', 14, 4.5),

    (57, '🂠', 0, 4.5),  (68, '🂠', 11, 0.5),
    (58, '🂠', 1, 4.5),  (69, '🂠', 12, 0.5),
    (59, '🂠', 2, 0.5),  (70, '🂠', 13, 0.5),
    (60, '🂠', 3, 0.5),  (71, '🂠', 14, 0.5),
    (61, '🂠', 4, 0.5),  (72, '🂠', 15, 0.5),
    (62, '🂠', 5, 0.5),  (73, '🂠', 16, 0.5),
    (63, '🂠', 6, 0.5),  (74, '🂠', 17, 0.5),
    (64, '🂠', 7, 0.5),  (75, '🂠', 18, 0.5),
    (65, '🂠', 8, 0.5),  (76, '🂠', 19, 0.5),
    (66, '🂠', 9, 0.5),  (77, '🂠', 20, 0.5),
    (67, '🂠', 10, 0.5), (78, '🂠', 21, 4.5)
;

create or replace function readonly_trigger_function() returns trigger as $$
begin
  raise exception 'The "%" table is read only!', TG_TABLE_NAME using hint = 'Look at tables that inherit from this table and write to them instead.';
  return null;
end;
$$ language 'plpgsql';

create trigger cards_readonly_trigger
before insert or update or delete or truncate on tarot.card
for each statement execute procedure readonly_trigger_function();

create or replace function tarot.generate()
returns smallint[] as
$$
    select array_agg(id) from (select id from tarot.card order by random()) tc;
$$ language sql;

create table if not exists tarot.gen (
    id serial primary key,
    cards smallint[] unique not null,
    resolved boolean not null default false,
    constraint cards_length check (array_length(cards, 1) = 78)
);

create or replace function valid_generation()
returns trigger as
$$
begin
    if (select sum(points) as points from unnest(tarot.generate()) g inner join tarot.card c on c.id=g) != 91 THEN
        raise exception 'Generation points sum if not 91';
    end if;
    return new;
end
$$ language plpgsql;

create trigger validate_generation
before insert or update on tarot.gen
for each row execute procedure valid_generation();

create table if not exists tarot.game (
    id serial primary key,
    players smallint not null default 4,
    gen_id integer not null,
    foreign key(gen_id) references tarot.gen (id),
    constraint players_range check (players between 3 and 5)
);

create table if not exists tarot.hand (
    id serial primary key,
    game_id integer not null,
    foreign key(game_id) references tarot.game (id)
);
