import sys
import pandas as pd
from keras.models import load_model

NN_model_name = r'NN_model.keras'
if __name__ == '__main__':
    if len(sys.argv) < 2:
        predict_filename = r'OUTres_rocket_test.csv'
    else:
        predict_filename = sys.argv[1]

    feature_list = ['hier', 'Rin', 'Rout', 'fanin', 'fanout', 'fanin_v', 'fanout_v', 'loop', 'length']
    model = load_model(NN_model_name)
    df = pd.read_csv(predict_filename)
    data_feature = df.loc[:, feature_list]
    data_score = model.predict(data_feature)
    df['score'] = data_score
    output_filename = 'huachiqiu.csv'
    df.to_csv(output_filename, index=0)
    print('Prediction finished!')

