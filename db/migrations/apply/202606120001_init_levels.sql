BEGIN;

DO $$
DECLARE patch_registered bool default false;
BEGIN
    SELECT _v.try_register_patch(
      '202606120001_init_levels',
      ARRAY['202605020005_create_levels'],
      'Seed initial level progression data'
    ) INTO patch_registered;

    IF patch_registered THEN
        INSERT INTO levels (name, order_index, child_levels, enemy_wave_config, question_gen_config)
        VALUES
          (
            'Level 1', 0, ARRAY['Level 2'],
            '{"schema":1,"data":{"enemies":["BasicEnemy"]}}',
            '{"schema":1,"data":{"stage":"AdditionStage"}}'
          ),
          (
            'Level 2', 1, ARRAY['Level 3'],
            '{"schema":1,"data":{"enemies":["TankyEnemy"]}}',
            '{"schema":1,"data":{"stage":"AdditionStage"}}'
          ),
          (
            'Level 3', 2, ARRAY['Level 4'],
            '{"schema":1,"data":{"enemies":["BasicEnemy","BasicEnemy"]}}',
            '{"schema":1,"data":{"stage":"SubtractionStage"}}'
          ),
          (
            'Level 4', 3, ARRAY['Level 5'],
            '{"schema":1,"data":{"enemies":["BasicEnemy","TankyEnemy"]}}',
            '{"schema":1,"data":{"stage":"SubtractionStage"}}'
          ),
          (
            'Level 5', 4, ARRAY['Level 6'],
            '{"schema":1,"data":{"enemies":["Boss Enemy Level 5"]}}',
            '{"schema":1,"data":{"stage":"SubtractionStage"}}'
          ),
          (
            'Level 6', 5, ARRAY['Level 7'],
            '{"schema":1,"data":{"enemies":["TankyEnemy","SwarmSpawnerEnemy"]}}',
            '{"schema":1,"data":{"stage":"MultiplicationStage"}}'
          ),
          (
            'Level 7', 6, ARRAY['Level 8'],
            '{"schema":1,"data":{"enemies":["BasicEnemy","SwarmSpawnerEnemy","SwarmSpawnerEnemy"]}}',
            '{"schema":1,"data":null}'
          ),
          (
            'Level 8', 7, ARRAY['Level 9'],
            '{"schema":1,"data":{"enemies":["SwarmSpawnerEnemy","SwarmSpawnerEnemy","SwarmSpawnerEnemy"]}}',
            '{"schema":1,"data":{"stage":"DivisionStage"}}'
          ),
          (
            'Level 9', 8, ARRAY['Level 10'],
            '{"schema":1,"data":{"enemies":["TankyEnemy","BasicEnemy","SwarmSpawnerEnemy","SwarmSpawnerEnemy"]}}',
            '{"schema":1,"data":null}'
          ),
          (
            'Level 10', 9, ARRAY['Level 11'],
            '{"schema":1,"data":{"enemies":["Boss Enemy"]}}',
            '{"schema":1,"data":null}'
          ),
          (
            'Level 11', 10, ARRAY['Level 12'],
            '{"schema":1,"data":{"enemies":["BasicEnemy","BasicEnemy","BasicEnemy"]}}',
            '{"schema":1,"data":{"stage":"FractionAdditionStage"}}'
          ),
          (
            'Level 12', 11, ARRAY['Level 13'],
            '{"schema":1,"data":{"enemies":["SwarmSpawnerEnemy","BasicEnemy","TankyEnemy","TankyEnemy"]}}',
            '{"schema":1,"data":{"stage":"FractionSubtractionStage"}}'
          ),
          (
            'Level 13', 12, ARRAY['Level 14'],
            '{"schema":1,"data":{"enemies":["BasicEnemy","BasicEnemy","BasicEnemy","BasicEnemy","BasicEnemy"]}}',
            '{"schema":1,"data":{"stage":"FractionMultiplicationStage"}}'
          ),
          (
            'Level 14', 13, ARRAY['Level 15'],
            '{"schema":1,"data":{"enemies":["BasicEnemy","BasicEnemy","SwarmSpawnerEnemy","SwarmSpawnerEnemy","TankyEnemy","BasicEnemy"]}}',
            '{"schema":1,"data":null}'
          ),
          (
            'Level 15', 14, NULL,
            '{"schema":1,"data":{"enemies":["Boss Enemy Level 15"]}}',
            '{"schema":1,"data":{"stage":"MultiplicationStage"}}'
          ),
          (
            'TestingLevel', -1, NULL,
            '{"schema":1,"data":{"enemies":["SwarmSpawnerEnemy","BasicEnemy"]}}',
            '{"schema":1,"data":null}'
          );
    END IF;
END $$;

COMMIT;
