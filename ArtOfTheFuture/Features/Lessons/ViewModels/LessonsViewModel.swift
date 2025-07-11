import SwiftUI
import Combine

final class LessonsViewModel: ObservableObject {
    @Published var lessons: [Lesson] = []
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?

    private var cancellables = Set<AnyCancellable>()
    private let lessonsService: LessonsServiceProtocol

    init(service: LessonsServiceProtocol = LessonsService()) {
        self.lessonsService = service
        loadLessons()
    }

    func loadLessons() {
        isLoading = true
        errorMessage = nil

        lessonsService.fetchLessons()
            .receive(on: DispatchQueue.main)
            .sink { [weak self] completion in
                guard let self = self else { return }
                self.isLoading = false
                if case let .failure(error) = completion {
                    self.errorMessage = error.localizedDescription
                }
            } receiveValue: { [weak self] lessons in
                self?.lessons = lessons
            }
            .store(in: &cancellables)
    }

    func refresh() {
        loadLessons()
    }

    func lessonTitle(at index: Int) -> String {
        guard lessons.indices.contains(index) else { return "–" }
        return lessons[index].title
    }
}
