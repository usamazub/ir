import matplotlib.pyplot as plt
import numpy as np

relevant_documents = [
    "KPS-30062019-030",
    "KPS-30062019-034",
    "KPS-30062019-035",
    "KPS-30062019-043",
    "KPS-30062019-050",
    "KPS-30062019-061",
    "KPS-30062019-096",
    "KPS-30062019-116",
]

file_names = [
    "pemilihan umum_documents.txt",
    "pemilihan umum presiden_documents.txt",
    "penetapan pemilihan umum presiden_documents.txt"
]

aps = []

total_files = [
    10, 20, 100
]

def calculate_ap(file_name, total_file = 10000):
    file = open(file_name, "r")
    
    relevant = 0
    document = 0

    precisions = []

    for line in file:
        arr = line.strip().split()

        if (arr[1][0] == "K"):
            document += 1

        if arr[1] in relevant_documents:
            relevant += 1
            precisions.append(relevant/document)
        
        if (total_file == document):
            break
    
    file.close()

    aps.append(sum(precisions)/len(precisions))

    return sum(precisions)/len(precisions)

def points_of_q(file_name):
    file = open(file_name, "r")
    
    relevant = 0
    document = 0

    ret = []

    for line in file:
        arr = line.strip().split()

        if (arr[1][0] == "K"):
            document += 1

        if arr[1] in relevant_documents:
            relevant += 1
            precision = round(relevant/document, 3)
            recall = round(relevant/len(relevant_documents), 3)
            ret.append((precision, recall))
        
        if (200 == document):
            break

    return ret


def precision_and_recall_graph_generator(list_of_names):
    points_of_q1 = points_of_q(list_of_names[0])
    points_of_q2 = points_of_q(list_of_names[1])
    points_of_q3 = points_of_q(list_of_names[2])

    q1_precisions = []
    q1_recalls = []

    for point in points_of_q1:
        q1_precisions.append(point[0])
        q1_recalls.append(point[1])
    
    q2_precisions = []
    q2_recalls = []

    for point in points_of_q2:
        q2_precisions.append(point[0])
        q2_recalls.append(point[1])
    
    q3_precisions = []
    q3_recalls = []

    for point in points_of_q3:
        q3_precisions.append(point[0])
        q3_recalls.append(point[1])
    
    plt.title("Grafik Precision dan Recall")
    plt.xticks([1/8, 2/8, 3/8, 4/8, 5/8, 6/8, 7/8, 8/8])
    plt.xlabel("recall")
    plt.ylabel("precision")
    plt.plot(q1_recalls, q1_precisions)
    plt.plot(q2_recalls, q2_precisions)
    plt.plot(q3_recalls, q3_precisions)
    plt.legend(['query 1', 'query 2', 'query 3'], loc='upper left')
    plt.show()


if __name__ == "__main__":
    # 2a
    file = open("MAP.txt", "w")

    for file_name in file_names:
        precision = calculate_ap(file_name = file_name)
        aps.append(precision)

        precision = round(precision, 3)
        file.write(file_name + " AP = " + str(precision) + "\n")
    
    file.write("\nMAP = " + str(round(sum(aps)/len(aps), 3)) + "\n")

    file.close()

    # 2b
    file = open("top_n_average_precision.txt", "w")
    for file_name in file_names:
        for total_file in total_files:
            top_n_average_precision = calculate_ap(file_name = file_name, total_file = total_file)
            top_n_average_precision = round(top_n_average_precision, 3)
            file.write(file_name + " top " + str(total_file) + " AP = " + str(top_n_average_precision) + "\n")
        file.write("\n")
    
    file.close()
    
    # 2c
    precision_and_recall_graph_generator(file_names)
