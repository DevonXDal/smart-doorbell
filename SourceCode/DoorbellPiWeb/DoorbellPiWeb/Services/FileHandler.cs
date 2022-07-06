using DoorbellPiWeb.Data;
using DoorbellPiWeb.Models.Db;
using Microsoft.AspNetCore.Hosting;
using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Mvc;
using Microsoft.AspNetCore.StaticFiles;
using Microsoft.Extensions.Configuration;
using Microsoft.Extensions.Logging;
using System;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using System.Text.RegularExpressions;
using System.Threading.Tasks;

namespace DoorbellPiWeb.Helpers.Services
{
    /// <summary>
    /// Handles the management of the filesystem
    /// </summary>
    public class FileHandler
    {
        private readonly UnitOfWork _unitOfWork;
        private readonly IConfiguration _configuration;
        private readonly ILogger<FileHandler> _logger;

        public FileHandler(UnitOfWork unitOfWork, IConfiguration config, ILogger<FileHandler> logger)
        {
            _unitOfWork = unitOfWork;
            _configuration = config;
            _logger = logger;
        }

        /// <summary>
        /// Creates the related file on the file system and makes a database association to it.
        /// </summary>
        /// <param name="file">The file to be created.</param>
        /// <param name="userId">The user to create the file for</param>
        /// <param name="fileSaveToId">The id for whatever the related file is associated with</param>
        /// <param name="fileSaveTo">The type of model that is storing the file</param>
        /// <param name="alteredFileName">A different file name to use</param>
        /// <returns>-1 if the file could not be created or the id of the new file.</returns>
        public int CreateRelatedFile(IFormFile file, int videoCallId, String? alteredFileName = null)
        {
            if (!TryFileCreationValidation(file, videoCallId))
            {
                return -1;
            }

            String filename = Regex.Replace(file.FileName, "/[/A-Za-z0-9-_ ]+\\//g", ""); //Used regexr.com
            if (alteredFileName is not null)
            {
                filename = alteredFileName;
            }

            String fileStoragePath = _configuration.GetSection("FileStoragePath").Value;
            String fileExtension = Path.GetExtension(filename); //= Regex.Match(file.FileName, "/\\..*$/g").ToString();
            String filenameGuid = Guid.NewGuid().ToString() + fileExtension;

            String fullFilePath = $"{fileStoragePath}{videoCallId}/{filenameGuid}";
            String relativePath = $"/filesystem/{videoCallId}/{filenameGuid}";

            FileStream fileStream = null;
            bool writtenSuccessfully = false;
            try
            {
                //https://stackoverflow.com/questions/39322085/how-to-save-iformfile-to-disk
                //https://www.completecsharptutorial.com/basic/c-file-handling-programming-examples-and-practice-question.php
                DirectoryInfo directory = new DirectoryInfo($"{fileStoragePath}/{videoCallId}");
                if (!directory.Exists)
                {
                    directory.Create();
                }

                fileStream = new FileStream(fullFilePath, FileMode.Create);
                file.CopyToAsync(fileStream).Wait();
                writtenSuccessfully = true;

            }
            catch (IOException e)
            {
                _logger.LogError(e, $"IO error writing file: {filename}, for video chat: {videoCallId}");
            }
            finally
            {
                if (fileStream is not null)
                {
                    fileStream.Close();
                    fileStream.Dispose();
                }
            }

            if (!writtenSuccessfully)
            {
                return -1; //File not stored
            }

            RelatedFile entity = new RelatedFile
            {
                FilePath = relativePath,
                FileName = filename,
            };

            _unitOfWork.RelatedFileRepo.Insert(entity);

            return entity.Id;
        }

        /// <summary>
        /// Determines whether the file is an image.
        /// </summary>
        /// <param name="file">The file to check</param>
        /// <returns>
        ///   <c>true</c> if the file is an image otherwise, <c>false</c>.
        /// </returns>
        public bool IsRelatedFileImage(IFormFile file) => file.ContentType.Contains("image/", StringComparison.OrdinalIgnoreCase);

        /// <summary>
        /// Gets the file an returns it as a file download result.
        /// </summary>
        /// <param name="file">The related file mapping entity from the database</param>
        /// <returns>The result to download a file on the client side</returns>
        public FileContentResult GetFile(RelatedFile file)
        {
            String filePath;

            filePath = GetAbsoluteFilePath(file);


            var mimeType = GetMimeType(filePath);

            byte[] fileBytes = null;
            try
            {
                fileBytes = File.ReadAllBytes(Path.GetFullPath(filePath));
                if (!File.Exists(filePath))
                {
                    _logger.LogError($"The file was not found on the system and could not be downloaded, path was: {filePath}");
                }
            }
            catch (IOException e)
            {
                _logger.LogError(e, $"An IOException was thrown attempting to access the file at path: {filePath}");
            }


            return new FileContentResult(fileBytes, mimeType);
        }

        /// <summary>
        /// Takes a RelatedFile and deletes its entity in the database and the actual file. 
        /// If it fails to delete the file then the RelatedFile entity is deleted and a log is created.
        /// </summary>
        /// <param name="file">The RelatedFile that should be removed from the system</param>
        public async Task DeleteFile(RelatedFile file)
        {
            try
            {
                String filePath = GetAbsoluteFilePath(file);
                if (!filePath.Contains("wwwroot"))
                {
                    File.Delete(filePath);
                }           
            }
            catch(Exception e)
            {
                _logger.LogError(e, "Failed to delete fail for RelatedFile, will leave file in filesystem storage.");
            }
            finally
            {
                _unitOfWork.RelatedFileRepo.Delete(_unitOfWork.RelatedFileRepo.GetByID(file.Id));
            }
        }

        //Returns the Mime type of the file (helps identify the type of file)
        private string GetMimeType(string fileName)
        {
            //https://stackoverflow.com/questions/45727856/how-to-download-a-file-in-asp-net-core
            var provider = new FileExtensionContentTypeProvider();
            string contentType;
            if (!provider.TryGetContentType(fileName, out contentType))
            {
                contentType = "application/octet-stream";
            }
            return contentType;
        }

        //Returns the absolute filepath depending on whether the filesystem path or wwwroot
        public String GetAbsoluteFilePath(RelatedFile file)
        {
            if (file.FilePath.StartsWith("/filesystem"))
            {
                return _configuration.GetSection("FileStoragePath").Value + file.FilePath.Replace("/filesystem/", "");
            }
            else
            {
                return "./wwwroot" + file.FilePath;
            }
        }

        //Uses the arguments for the parameters to do similar validation. Returns false if validation failed.
        private bool TryFileCreationValidation(Object file, int fileSaveToId)
        {
            if (fileSaveToId == 0)
            {
                _logger.LogError("File creation failed due to no associated id");
                return false; //Nothing to associate with the file
            }
            else if (file is null)
            {
                _logger.LogWarning("No file sent to be manipulated");
                return false; //No file
            }
            else
            {
                return true;
            }
        }
    }
}
