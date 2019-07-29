import sys
import pandas as pd
from sklearn.model_selection import train_test_split
from keras.models import Sequential
from keras.layers.core import Dense, Activation


if __name__ == '__main__':
    if len(sys.argv) < 2:
        train_filename = r'train_set_score_2.csv'
    else:
        train_filename = sys.argv[1]

    feature_list = ['hier', 'Rin', 'Rout', 'fanin', 'fanout', 'fanin_v', 'fanout_v', 'loop', 'length']
    df = pd.read_csv(train_filename)

    data_feature = df.loc[:, feature_list]
    data_score = df.loc[:, 'score']
    feature_train, feature_test, score_train, score_test = train_test_split(data_feature, data_score, test_size=0.1,
                                                                            random_state=0)
    model = Sequential()
    model.add(Dense(100, activation='relu', kernel_initializer='uniform', input_dim=len(feature_list)))
    model.add(Dense(1, activation='sigmoid'))
    model.compile(optimizer='rmsprop', loss='mean_squared_error', metrics=['accuracy'])

    hist = model.fit(feature_train, score_train, batch_size=15, epochs=100, shuffle=True, validation_split=0.2)
    score = model.evaluate(feature_train, score_train, batch_size=15)

    model.save('NN_model.keras')
    print('model has been saved!')




