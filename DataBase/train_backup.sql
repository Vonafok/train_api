PGDMP                         {            train1    15.3    15.3 E    c           0    0    ENCODING    ENCODING        SET client_encoding = 'UTF8';
                      false            d           0    0 
   STDSTRINGS 
   STDSTRINGS     (   SET standard_conforming_strings = 'on';
                      false            e           0    0 
   SEARCHPATH 
   SEARCHPATH     8   SELECT pg_catalog.set_config('search_path', '', false);
                      false            f           1262    17119    train1    DATABASE     z   CREATE DATABASE train1 WITH TEMPLATE = template0 ENCODING = 'UTF8' LOCALE_PROVIDER = libc LOCALE = 'Russian_Russia.1251';
    DROP DATABASE train1;
                postgres    false            �            1255    17279 =   combined_function(bigint, bigint, bigint, bigint[], bigint[])    FUNCTION     �  CREATE FUNCTION public.combined_function(id_client bigint, id_arrival_timetable bigint, id_departure_timetable bigint, id_place_arr bigint[], id_person bigint[]) RETURNS TABLE(booking_id bigint, boughtplace_id bigint)
    LANGUAGE plpgsql
    AS $$
DECLARE
    booking_id BIGINT;
    boughtplace_ids BIGINT[];
	temp_booking_id bigint;
BEGIN
    -- Проверка условия
    WITH check_places AS (
        SELECT bp.id_place
        FROM boughtplace bp
        JOIN (
            SELECT DISTINCT b.id_booking
            FROM booking b
            JOIN (
                SELECT tim.id_timetable
                FROM timetable ta 
                JOIN timetable td ON td.id_timetable = id_arrival_timetable
                JOIN station sa ON ta.id_station = sa.id_station
                JOIN station sd ON td.id_station = sd.id_station
                JOIN station s ON s.serial_number_station BETWEEN sa.serial_number_station AND sd.serial_number_station
                JOIN timetable tim ON tim.id_station = s.id_station
                WHERE ta.id_timetable = id_departure_timetable
            ) sub ON sub.id_timetable = b.id_arrival_timetable OR sub.id_timetable = b.id_departure_timetable
        ) zak ON zak.id_booking = bp.id_booking
        WHERE bp.id_place = ANY(id_place_arr)
    )
    SELECT array_agg(id_place) INTO boughtplace_ids FROM check_places;

    -- Если проверка вернула значения, вернуть их
	IF boughtplace_ids IS NOT NULL THEN
    	RETURN QUERY
    	SELECT -1::bigint AS booking_id, unnest(boughtplace_ids) AS boughtplace_id;
		RETURN;
	END IF;


    -- Выполняем insert_booking и получаем id_booking
    booking_id := insert_booking(id_client, id_arrival_timetable, id_departure_timetable);

    -- Выполняем insert_boughtplace и получаем id_boughtplace
    boughtplace_ids := ARRAY(Select * from insert_boughtplace(booking_id, id_place_arr));

    -- Выполняем insert_booking_person
    PERFORM insert_booking_person(booking_id, id_person);

    -- Возвращаем значения id_boughtplace
	temp_booking_id := booking_id;
    RETURN QUERY
    SELECT temp_booking_id, unnest(boughtplace_ids) AS boughtplace_id;
	RETURN;
END;
$$;
 �   DROP FUNCTION public.combined_function(id_client bigint, id_arrival_timetable bigint, id_departure_timetable bigint, id_place_arr bigint[], id_person bigint[]);
       public          postgres    false            �            1255    17263 &   insert_booking(bigint, bigint, bigint)    FUNCTION     �  CREATE FUNCTION public.insert_booking(id_client bigint, id_arrival_timetable bigint, id_departure_timetable bigint) RETURNS bigint
    LANGUAGE plpgsql
    AS $$
DECLARE
    booking_id BIGINT;
BEGIN
    INSERT INTO booking (id_client, id_arrival_timetable, id_departure_timetable)
    VALUES (id_client, id_arrival_timetable, id_departure_timetable)
    RETURNING id_booking INTO booking_id;

    RETURN booking_id;
END;
$$;
 s   DROP FUNCTION public.insert_booking(id_client bigint, id_arrival_timetable bigint, id_departure_timetable bigint);
       public          postgres    false            �            1255    17265 '   insert_booking_person(bigint, bigint[])    FUNCTION     P  CREATE FUNCTION public.insert_booking_person(id_booking bigint, id_person bigint[]) RETURNS void
    LANGUAGE plpgsql
    AS $$
DECLARE
    person_id BIGINT;
BEGIN
    FOREACH person_id IN ARRAY id_person
    LOOP
        INSERT INTO booking_person (id_booking, id_person)
        VALUES (id_booking, person_id);
    END LOOP;
END;
$$;
 S   DROP FUNCTION public.insert_booking_person(id_booking bigint, id_person bigint[]);
       public          postgres    false            �            1255    17275 $   insert_boughtplace(bigint, bigint[])    FUNCTION       CREATE FUNCTION public.insert_boughtplace(id_booking bigint, id_place bigint[]) RETURNS SETOF bigint
    LANGUAGE plpgsql
    AS $$
DECLARE
    boughtplace_id BIGINT;
    i INT;
BEGIN
    FOR i IN 1..array_length(id_place, 1)
    LOOP
        INSERT INTO boughtplace (id_booking, id_place)
        VALUES (id_booking, id_place[i])
        RETURNING id_boughtplace INTO boughtplace_id;

        -- Возвращаем boughtplace_id с помощью SETOF
        RETURN NEXT boughtplace_id;
    END LOOP;
    
    RETURN;
END;
$$;
 O   DROP FUNCTION public.insert_boughtplace(id_booking bigint, id_place bigint[]);
       public          postgres    false            �            1259    17121    booking    TABLE     �   CREATE TABLE public.booking (
    id_booking bigint NOT NULL,
    id_client bigint NOT NULL,
    timedate_booking timestamp without time zone DEFAULT now(),
    id_arrival_timetable bigint NOT NULL,
    id_departure_timetable bigint NOT NULL
);
    DROP TABLE public.booking;
       public         heap    postgres    false            �            1259    17120    booking_id_booking_seq    SEQUENCE        CREATE SEQUENCE public.booking_id_booking_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 -   DROP SEQUENCE public.booking_id_booking_seq;
       public          postgres    false    215            g           0    0    booking_id_booking_seq    SEQUENCE OWNED BY     Q   ALTER SEQUENCE public.booking_id_booking_seq OWNED BY public.booking.id_booking;
          public          postgres    false    214            �            1259    17126    booking_person    TABLE     f   CREATE TABLE public.booking_person (
    id_booking bigint NOT NULL,
    id_person bigint NOT NULL
);
 "   DROP TABLE public.booking_person;
       public         heap    postgres    false            �            1259    17130    boughtplace    TABLE     �   CREATE TABLE public.boughtplace (
    id_boughtplace bigint NOT NULL,
    id_place bigint NOT NULL,
    id_booking bigint NOT NULL
);
    DROP TABLE public.boughtplace;
       public         heap    postgres    false            �            1259    17129    boughtplace_id_boughtplace_seq    SEQUENCE     �   CREATE SEQUENCE public.boughtplace_id_boughtplace_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 5   DROP SEQUENCE public.boughtplace_id_boughtplace_seq;
       public          postgres    false    218            h           0    0    boughtplace_id_boughtplace_seq    SEQUENCE OWNED BY     a   ALTER SEQUENCE public.boughtplace_id_boughtplace_seq OWNED BY public.boughtplace.id_boughtplace;
          public          postgres    false    217            �            1259    17134    client    TABLE     ]   CREATE TABLE public.client (
    id_client bigint NOT NULL,
    id_person bigint NOT NULL
);
    DROP TABLE public.client;
       public         heap    postgres    false            �            1259    17137    person    TABLE     J  CREATE TABLE public.person (
    id_person bigint NOT NULL,
    firstname_person character varying(50) NOT NULL,
    lastname_person character varying(50) NOT NULL,
    patronymic_person character varying(50),
    seriespassport_person character varying(4),
    numberpassport_person character varying(6),
    date_person date
);
    DROP TABLE public.person;
       public         heap    postgres    false            �            1259    17140    place    TABLE     �   CREATE TABLE public.place (
    id_place bigint NOT NULL,
    id_wagon bigint NOT NULL,
    number_place integer NOT NULL,
    id_placetype integer NOT NULL
);
    DROP TABLE public.place;
       public         heap    postgres    false            �            1259    17143 	   placetype    TABLE       CREATE TABLE public.placetype (
    id_placetype integer NOT NULL,
    name_placetype character varying(10),
    description_placetype character varying(100),
    standart_placetype numeric(10,2),
    preferential_placetype numeric(10,2),
    discount_placetype numeric(10,2)
);
    DROP TABLE public.placetype;
       public         heap    postgres    false            �            1259    17146    railwaystation    TABLE       CREATE TABLE public.railwaystation (
    id_railwaystation bigint NOT NULL,
    localityname_railwaystation character varying(100),
    name_railwaystation character varying(100),
    platform_railwaystation character varying(10),
    timezone_railwaystation integer
);
 "   DROP TABLE public.railwaystation;
       public         heap    postgres    false            �            1259    17149    route    TABLE     x   CREATE TABLE public.route (
    id_route bigint NOT NULL,
    name_route character varying(100),
    id_train bigint
);
    DROP TABLE public.route;
       public         heap    postgres    false            �            1259    17152    station    TABLE     �   CREATE TABLE public.station (
    id_station bigint NOT NULL,
    serial_number_station integer NOT NULL,
    id_route bigint NOT NULL,
    id_railwaystation integer NOT NULL
);
    DROP TABLE public.station;
       public         heap    postgres    false            �            1259    17155 	   timetable    TABLE     
  CREATE TABLE public.timetable (
    id_timetable bigint NOT NULL,
    id_station bigint NOT NULL,
    timedatearrival_timetable timestamp without time zone,
    timedatedepartyre_timetable timestamp without time zone,
    platform_timestamp character varying(10)
);
    DROP TABLE public.timetable;
       public         heap    postgres    false            �            1259    17158    train    TABLE     �   CREATE TABLE public.train (
    id_train bigint NOT NULL,
    number_train character varying(10),
    type_train character varying(100),
    numberfromhead_train boolean
);
    DROP TABLE public.train;
       public         heap    postgres    false            �            1259    17161    wagon    TABLE     y   CREATE TABLE public.wagon (
    id_wagon bigint NOT NULL,
    number_wagon character varying(10),
    id_train bigint
);
    DROP TABLE public.wagon;
       public         heap    postgres    false            �           2604    17124    booking id_booking    DEFAULT     x   ALTER TABLE ONLY public.booking ALTER COLUMN id_booking SET DEFAULT nextval('public.booking_id_booking_seq'::regclass);
 A   ALTER TABLE public.booking ALTER COLUMN id_booking DROP DEFAULT;
       public          postgres    false    215    214    215            �           2604    17133    boughtplace id_boughtplace    DEFAULT     �   ALTER TABLE ONLY public.boughtplace ALTER COLUMN id_boughtplace SET DEFAULT nextval('public.boughtplace_id_boughtplace_seq'::regclass);
 I   ALTER TABLE public.boughtplace ALTER COLUMN id_boughtplace DROP DEFAULT;
       public          postgres    false    218    217    218            S          0    17121    booking 
   TABLE DATA           x   COPY public.booking (id_booking, id_client, timedate_booking, id_arrival_timetable, id_departure_timetable) FROM stdin;
    public          postgres    false    215   Zb       T          0    17126    booking_person 
   TABLE DATA           ?   COPY public.booking_person (id_booking, id_person) FROM stdin;
    public          postgres    false    216   �b       V          0    17130    boughtplace 
   TABLE DATA           K   COPY public.boughtplace (id_boughtplace, id_place, id_booking) FROM stdin;
    public          postgres    false    218   �b       W          0    17134    client 
   TABLE DATA           6   COPY public.client (id_client, id_person) FROM stdin;
    public          postgres    false    219   c       X          0    17137    person 
   TABLE DATA           �   COPY public.person (id_person, firstname_person, lastname_person, patronymic_person, seriespassport_person, numberpassport_person, date_person) FROM stdin;
    public          postgres    false    220   Wc       Y          0    17140    place 
   TABLE DATA           O   COPY public.place (id_place, id_wagon, number_place, id_placetype) FROM stdin;
    public          postgres    false    221   �e       Z          0    17143 	   placetype 
   TABLE DATA           �   COPY public.placetype (id_placetype, name_placetype, description_placetype, standart_placetype, preferential_placetype, discount_placetype) FROM stdin;
    public          postgres    false    222   Pf       [          0    17146    railwaystation 
   TABLE DATA           �   COPY public.railwaystation (id_railwaystation, localityname_railwaystation, name_railwaystation, platform_railwaystation, timezone_railwaystation) FROM stdin;
    public          postgres    false    223   �f       \          0    17149    route 
   TABLE DATA           ?   COPY public.route (id_route, name_route, id_train) FROM stdin;
    public          postgres    false    224   �h       ]          0    17152    station 
   TABLE DATA           a   COPY public.station (id_station, serial_number_station, id_route, id_railwaystation) FROM stdin;
    public          postgres    false    225   �h       ^          0    17155 	   timetable 
   TABLE DATA           �   COPY public.timetable (id_timetable, id_station, timedatearrival_timetable, timedatedepartyre_timetable, platform_timestamp) FROM stdin;
    public          postgres    false    226   �i       _          0    17158    train 
   TABLE DATA           Y   COPY public.train (id_train, number_train, type_train, numberfromhead_train) FROM stdin;
    public          postgres    false    227   Ak       `          0    17161    wagon 
   TABLE DATA           A   COPY public.wagon (id_wagon, number_wagon, id_train) FROM stdin;
    public          postgres    false    228   �k       i           0    0    booking_id_booking_seq    SEQUENCE SET     E   SELECT pg_catalog.setval('public.booking_id_booking_seq', 15, true);
          public          postgres    false    214            j           0    0    boughtplace_id_boughtplace_seq    SEQUENCE SET     M   SELECT pg_catalog.setval('public.boughtplace_id_boughtplace_seq', 35, true);
          public          postgres    false    217            �           2606    17165    booking booking_pkey 
   CONSTRAINT     Z   ALTER TABLE ONLY public.booking
    ADD CONSTRAINT booking_pkey PRIMARY KEY (id_booking);
 >   ALTER TABLE ONLY public.booking DROP CONSTRAINT booking_pkey;
       public            postgres    false    215            �           2606    17167    boughtplace boughtplace_pkey 
   CONSTRAINT     f   ALTER TABLE ONLY public.boughtplace
    ADD CONSTRAINT boughtplace_pkey PRIMARY KEY (id_boughtplace);
 F   ALTER TABLE ONLY public.boughtplace DROP CONSTRAINT boughtplace_pkey;
       public            postgres    false    218            �           2606    17169    client client_pkey 
   CONSTRAINT     W   ALTER TABLE ONLY public.client
    ADD CONSTRAINT client_pkey PRIMARY KEY (id_client);
 <   ALTER TABLE ONLY public.client DROP CONSTRAINT client_pkey;
       public            postgres    false    219            �           2606    17171    person person_pkey 
   CONSTRAINT     W   ALTER TABLE ONLY public.person
    ADD CONSTRAINT person_pkey PRIMARY KEY (id_person);
 <   ALTER TABLE ONLY public.person DROP CONSTRAINT person_pkey;
       public            postgres    false    220            �           2606    17173    place place_pkey 
   CONSTRAINT     T   ALTER TABLE ONLY public.place
    ADD CONSTRAINT place_pkey PRIMARY KEY (id_place);
 :   ALTER TABLE ONLY public.place DROP CONSTRAINT place_pkey;
       public            postgres    false    221            �           2606    17175    placetype placetype_pkey 
   CONSTRAINT     `   ALTER TABLE ONLY public.placetype
    ADD CONSTRAINT placetype_pkey PRIMARY KEY (id_placetype);
 B   ALTER TABLE ONLY public.placetype DROP CONSTRAINT placetype_pkey;
       public            postgres    false    222            �           2606    17177 "   railwaystation railwaystation_pkey 
   CONSTRAINT     o   ALTER TABLE ONLY public.railwaystation
    ADD CONSTRAINT railwaystation_pkey PRIMARY KEY (id_railwaystation);
 L   ALTER TABLE ONLY public.railwaystation DROP CONSTRAINT railwaystation_pkey;
       public            postgres    false    223            �           2606    17179    route route_pkey 
   CONSTRAINT     T   ALTER TABLE ONLY public.route
    ADD CONSTRAINT route_pkey PRIMARY KEY (id_route);
 :   ALTER TABLE ONLY public.route DROP CONSTRAINT route_pkey;
       public            postgres    false    224            �           2606    17181    station station_pkey 
   CONSTRAINT     Z   ALTER TABLE ONLY public.station
    ADD CONSTRAINT station_pkey PRIMARY KEY (id_station);
 >   ALTER TABLE ONLY public.station DROP CONSTRAINT station_pkey;
       public            postgres    false    225            �           2606    17183    timetable timetable_pkey 
   CONSTRAINT     `   ALTER TABLE ONLY public.timetable
    ADD CONSTRAINT timetable_pkey PRIMARY KEY (id_timetable);
 B   ALTER TABLE ONLY public.timetable DROP CONSTRAINT timetable_pkey;
       public            postgres    false    226            �           2606    17185    train train_pkey 
   CONSTRAINT     T   ALTER TABLE ONLY public.train
    ADD CONSTRAINT train_pkey PRIMARY KEY (id_train);
 :   ALTER TABLE ONLY public.train DROP CONSTRAINT train_pkey;
       public            postgres    false    227            �           2606    17187    wagon wagon_pkey 
   CONSTRAINT     T   ALTER TABLE ONLY public.wagon
    ADD CONSTRAINT wagon_pkey PRIMARY KEY (id_wagon);
 :   ALTER TABLE ONLY public.wagon DROP CONSTRAINT wagon_pkey;
       public            postgres    false    228            �           2606    17188    booking fk_booking_client    FK CONSTRAINT     �   ALTER TABLE ONLY public.booking
    ADD CONSTRAINT fk_booking_client FOREIGN KEY (id_client) REFERENCES public.client(id_client);
 C   ALTER TABLE ONLY public.booking DROP CONSTRAINT fk_booking_client;
       public          postgres    false    219    215    3234            �           2606    17280 (   booking_person fk_booking_person_booking    FK CONSTRAINT     �   ALTER TABLE ONLY public.booking_person
    ADD CONSTRAINT fk_booking_person_booking FOREIGN KEY (id_booking) REFERENCES public.booking(id_booking) ON DELETE CASCADE;
 R   ALTER TABLE ONLY public.booking_person DROP CONSTRAINT fk_booking_person_booking;
       public          postgres    false    215    3230    216            �           2606    17198 '   booking_person fk_booking_person_person    FK CONSTRAINT     �   ALTER TABLE ONLY public.booking_person
    ADD CONSTRAINT fk_booking_person_person FOREIGN KEY (id_person) REFERENCES public.person(id_person);
 Q   ALTER TABLE ONLY public.booking_person DROP CONSTRAINT fk_booking_person_person;
       public          postgres    false    3236    220    216            �           2606    17203    booking fk_booking_timetable1    FK CONSTRAINT     �   ALTER TABLE ONLY public.booking
    ADD CONSTRAINT fk_booking_timetable1 FOREIGN KEY (id_arrival_timetable) REFERENCES public.timetable(id_timetable);
 G   ALTER TABLE ONLY public.booking DROP CONSTRAINT fk_booking_timetable1;
       public          postgres    false    215    226    3248            �           2606    17208    booking fk_booking_timetable2    FK CONSTRAINT     �   ALTER TABLE ONLY public.booking
    ADD CONSTRAINT fk_booking_timetable2 FOREIGN KEY (id_departure_timetable) REFERENCES public.timetable(id_timetable);
 G   ALTER TABLE ONLY public.booking DROP CONSTRAINT fk_booking_timetable2;
       public          postgres    false    215    226    3248            �           2606    17285 "   boughtplace fk_boughtplace_booking    FK CONSTRAINT     �   ALTER TABLE ONLY public.boughtplace
    ADD CONSTRAINT fk_boughtplace_booking FOREIGN KEY (id_booking) REFERENCES public.booking(id_booking) ON DELETE CASCADE;
 L   ALTER TABLE ONLY public.boughtplace DROP CONSTRAINT fk_boughtplace_booking;
       public          postgres    false    215    3230    218            �           2606    17218     boughtplace fk_boughtplace_place    FK CONSTRAINT     �   ALTER TABLE ONLY public.boughtplace
    ADD CONSTRAINT fk_boughtplace_place FOREIGN KEY (id_place) REFERENCES public.place(id_place);
 J   ALTER TABLE ONLY public.boughtplace DROP CONSTRAINT fk_boughtplace_place;
       public          postgres    false    3238    218    221            �           2606    17223    client fk_client_person    FK CONSTRAINT     �   ALTER TABLE ONLY public.client
    ADD CONSTRAINT fk_client_person FOREIGN KEY (id_person) REFERENCES public.person(id_person);
 A   ALTER TABLE ONLY public.client DROP CONSTRAINT fk_client_person;
       public          postgres    false    3236    220    219            �           2606    17228    place fk_place_placetype    FK CONSTRAINT     �   ALTER TABLE ONLY public.place
    ADD CONSTRAINT fk_place_placetype FOREIGN KEY (id_placetype) REFERENCES public.placetype(id_placetype);
 B   ALTER TABLE ONLY public.place DROP CONSTRAINT fk_place_placetype;
       public          postgres    false    222    3240    221            �           2606    17233    place fk_place_wagon    FK CONSTRAINT     z   ALTER TABLE ONLY public.place
    ADD CONSTRAINT fk_place_wagon FOREIGN KEY (id_wagon) REFERENCES public.wagon(id_wagon);
 >   ALTER TABLE ONLY public.place DROP CONSTRAINT fk_place_wagon;
       public          postgres    false    228    221    3252            �           2606    17238    route fk_route_train    FK CONSTRAINT     z   ALTER TABLE ONLY public.route
    ADD CONSTRAINT fk_route_train FOREIGN KEY (id_train) REFERENCES public.train(id_train);
 >   ALTER TABLE ONLY public.route DROP CONSTRAINT fk_route_train;
       public          postgres    false    224    227    3250            �           2606    17243 !   station fk_station_railwaystation    FK CONSTRAINT     �   ALTER TABLE ONLY public.station
    ADD CONSTRAINT fk_station_railwaystation FOREIGN KEY (id_railwaystation) REFERENCES public.railwaystation(id_railwaystation);
 K   ALTER TABLE ONLY public.station DROP CONSTRAINT fk_station_railwaystation;
       public          postgres    false    223    3242    225            �           2606    17248    station fk_station_route    FK CONSTRAINT     ~   ALTER TABLE ONLY public.station
    ADD CONSTRAINT fk_station_route FOREIGN KEY (id_route) REFERENCES public.route(id_route);
 B   ALTER TABLE ONLY public.station DROP CONSTRAINT fk_station_route;
       public          postgres    false    225    224    3244            �           2606    17253    timetable fk_timetable_station    FK CONSTRAINT     �   ALTER TABLE ONLY public.timetable
    ADD CONSTRAINT fk_timetable_station FOREIGN KEY (id_station) REFERENCES public.station(id_station);
 H   ALTER TABLE ONLY public.timetable DROP CONSTRAINT fk_timetable_station;
       public          postgres    false    225    3246    226            �           2606    17258    wagon fk_wagon_train    FK CONSTRAINT     z   ALTER TABLE ONLY public.wagon
    ADD CONSTRAINT fk_wagon_train FOREIGN KEY (id_train) REFERENCES public.train(id_train);
 >   ALTER TABLE ONLY public.wagon DROP CONSTRAINT fk_wagon_train;
       public          postgres    false    227    3250    228            S   S   x��ͱ�0D�ڞ"$���y���(�h��O:�sw�f�D��	�����	�<���'_�[�z	��@���P��B�      T      x�34�4�24�4����� �      V   $   x�3�4�4�2�4�&�&���\Ʀ�� :F��� H�K      W   /   x��I   �����(��:H���L'�Ų(7���r� ������      X   �  x��T[N1���2��=�7����@*PJUQ����G�4iȃ5\�s�L |T�(����l2��;��}�/#�_y��r�+�dn����y�]92u$g|���rN������	�����֯��y��+�<���-ZkBHm Zj�_a~������b��Qw�0W�L��m���Q� P���Q�u�.\��c|��� ��XxO`Ѻ:�E�*r�w�6|��pNVU���S��a���@��3�XS�$X�r�"���P��/凸3e=��(&�Y��@���mE�}�J�(����P9�4� cj(KZ-�+J6	6
{|��S������|VЩ�51{��.�!�,+�(Nk �?cU4쨜�����ب��4����Ԛ��樜q>T33%"0��P^L��>�x�~I�4�AQ�
�ߣ�0h_w<Y��R5�R\ ���1��F������ Y�FR�B�ORފ���vF��E7���k�+u�-�9��k�p��ͽ2R>W�#�s1�(�Z��!�i*�-i�;Tk"�Cg�h�P|PA������&��Zj�>}$9��yn�[/V�6�i�I+wRlM�}dV[/���Kx�R��)�`)�{���>b�T��&f���^�&*I�x�����MyI�O�碼�+��+k�4$��      Y   A   x����@�޸�������A#��r���\a���¡�S�n-<Z�hf���m��i�û;�R      Z   _   x�3估���.�]�$.6q^�ta+��za�����
@�}@@YN#c=NCKmd������۰a3�b������%W� �CP      [   �  x��TMN�`]�)X��R��'�0�C�Q�*(n\�B
��|7�����BXmg���͛)~��iC!�R��E4����
w�L�
�l���b��|��	PA����
�{���9�\�)�<r��⦊@j��ꑐ�[|����_J�1*ǈw�]� ���ಀ{�jn%>��i����2�q��+���a�,q�eo���E&=����cR�z4B�:(�pX#��;GQ�<z�5�MQ�:����y�u@˄5&v���-Pm������э�$�$�U��Rj�Ep1ETN���?܄�Z��>�3�v�y�v`�7�%4F8ϐ�A�M���߮�q� �$�wႭ����l��SOF�Vu(̝`X[���{�Ms5��S��2�-�;�@��+�q�t�c�=���ł��u}���>P�>ia�EsoK���B�$�w���&�l��V�[̱X��:�$��oD^���Tβ��I�U      \   )   x�3�0��^ �pa����_�q���֋��\1z\\\ V�}      ]   �   x��ۍE1�M1������_��Q"��hF������٘5���sa�vn�:΃[�y��98*�������:'hz\�qp�vD�Z/hSd|�(Ŧu)\54K�jB���K�jC��tK��B��zT���-�hUg�䞾������[�jk�� �--�      ^   �  x�m��y�0�ϸ�4��4���4�
�Ai��\�g,� �@�X�=8���һ�Ґ�Ծ.&�Q�(Wn����GL�Xm���+i@�\����}e���ыN��P	H�Y��*�T���z�Qs�:ɱ��Uީ��f�*G"xXݛ��p���0�G�R4��m��ҵj���eP��G:��/2�%>zj��.�`��9�m�� �4������]k>����[�I̃�ZOm��-f��]�3�vKl1��QG>�j��-f�t?��<r,f�4�+[�9@�-�����x��k���b~K�Η+܇���Ʊ���R4��X-��Ė���[��C��0�;	�q�����$��84L�O�[���h�ZH3�|^��.Q%�      _   =   x�3�42�t�0�¾/l�����.#NCK�9A��/�_�{���N�4�=... �Am      `      x�3�4�4����� �Z     